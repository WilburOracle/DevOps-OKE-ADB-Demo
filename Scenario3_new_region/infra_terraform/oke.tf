# https://registry.terraform.io/modules/oracle-terraform-modules/oke/oci/latest
module "oke" {
    source  = "oracle-terraform-modules/oke/oci"
    version = "5.3.2"

    tenancy_id     = var.tenancy_ocid
    compartment_id = var.compartment_ocid

  # Identity
  create_iam_resources     = true

  # Network
  create_vcn                  = true
  vcn_name                    = var.vcn_name

  # Bastion
  create_bastion              = var.create_bastion
  bastion_allowed_cidrs    = ["0.0.0.0/0"]
  bastion_user             = "opc"
  # Operator
  create_operator                = var.create_operator

  # SSH
  ssh_public_key  = local.ssh_public_key
  ssh_private_key = sensitive(local.ssh_key_bundle_content)

  # Cluster
  create_cluster          = true
  cluster_name            = var.cluster_name
  kubernetes_version      = var.kubernetes_version
  cluster_type            = lower(var.cluster_type)
  cni_type                = lower(var.cni_type)
  load_balancers          = lower(var.load_balancers)
  preferred_load_balancer = lower(var.preferred_load_balancer)

  control_plane_is_public = true
  control_plane_allowed_cidrs  = ["0.0.0.0/0"]
  assign_public_ip_to_control_plane = true
  worker_is_public = false

  allow_node_port_access       = true
  allow_worker_internet_access = true
  allow_worker_ssh_access      = true
  

  # Workers
  worker_pool_size = var.worker_pool_size
  worker_pool_mode = lookup({
    "Node Pool"       = "node-pool"
    "Instances"       = "instance"
    "Instance Pool"   = "instance-pool",
    "Cluster Network" = "cluster-network",
  }, var.worker_pool_mode, "node-pool")


  worker_shape = {
    shape            = var.worker_shape
    ocpus            = var.worker_ocpus
    memory           = var.worker_memory
    boot_volume_size = var.worker_boot_volume_size
  }

  worker_pools = {
    format("%v", var.worker_pool_name) = {
      description = lookup({
        "Node Pool"       = "OKE-managed Node Pool"
        "Instances"       = "Self-managed Instances"
        "Instance Pool"   = "Self-managed Instance Pool"
        "Cluster Network" = "Self-managed Cluster Network"
      }, var.worker_pool_mode, "")
    }
  }

    providers = {
    oci      = oci
    oci.home = oci.home
  }
}

# 获取公共端点的 kubeconfig
data "oci_containerengine_cluster_kube_config" "kube_config_public" {
  cluster_id   = module.oke.cluster_id  # 引用模块输出的集群 ID
  endpoint = "PUBLIC_ENDPOINT"     # 过滤公共端点
}

# 获取私有端点的 kubeconfig
data "oci_containerengine_cluster_kube_config" "kube_config_private" {
  cluster_id   = module.oke.cluster_id  # 引用模块输出的集群 ID
  endpoint = "PRIVATE_ENDPOINT"    # 过滤私有端点
}

# 示例：存储公共端点的 kubeconfig 到文件
resource "local_file" "kube_config_public" {
  content         = data.oci_containerengine_cluster_kube_config.kube_config_public.content
  filename        = "init/kubeconfig"
  file_permission = "0600"
}

resource "null_resource" "oke_initialization" {
  depends_on = [oci_database_autonomous_database.tf_database_autonomous_database, module.oke.cluster_kubeconfig]

  provisioner "local-exec" {
    command = <<EOT
      sed "s/<<APP_VERSION>>/1.0.0/g" init/app-demo-template.yaml | \
      sed "s/<<DB_USER>>/ouser/g" | \
      sed "s/<<DB_PASSWORD>>/Oracle1234567/g" | \
      sed "s/<<DB_HOST>>/${local.adb_host}/g" | \
      sed "s/<<DB_SERVICE_NAME>>/${local.adb_service_name}/g" > init/app-demo.yaml
      kubectl apply -f init/app-demo.yaml --kubeconfig init/kubeconfig
    EOT
  }
}


output "oke_cluster_id" {
  value = module.oke.cluster_id
}

output "oke_name" {
  value = var.cluster_name
}

output "vcn_name" {
  value = var.vcn_name
}

output "kubeconfig" {
  value     = module.oke.cluster_kubeconfig
  sensitive = false
}

