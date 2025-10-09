#*************************************
#           OKE Settings
#*************************************
variable "vcn_name" {
  default = null
  type    = string
}

variable "cluster_type" {
  description = "The cluster type. See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengworkingwithenhancedclusters.htm>Working with Enhanced Clusters and Basic Clusters</a> for more information. NOTE: An Enhanced cluster is required for self-managed worker pools (mode != Node Pool)."
  type        = string
}
variable "cluster_name" {
  description = "OKE cluster name"
  type        = string
  default     = "oke-cluster"
}
variable "cni_type" { type = string }

variable "kubernetes_version" { 
  description = "Kubernetes version for the OKE control plane"
  type        = string
  default = "v1.32.1"
   }

variable "load_balancers" {
  default = "Public"
  type    = string
}

variable "preferred_load_balancer" {
  default = "Public"
  type    = string
}

# Worker pools
variable "worker_pool_mode" {
  default = "Node Pool"
  type    = string
  validation {
    condition     = contains(["Node Pool", "Instances", "Instance Pool", "Cluster Network"], var.worker_pool_mode)
    error_message = "Accepted values are Node Pool, Instances, Instance Pool, or Cluster Network"
  }
}
variable "worker_pool_size" {
  default = 1
  type    = number
}

# Workers: instance
variable "worker_pool_name" { type = string }

variable "worker_shape" { default = "VM.Standard.E4.Flex" }
variable "worker_ocpus" { default = 1 }
variable "worker_memory" { default = 16 }
variable "worker_boot_volume_size" { default = 50 }



