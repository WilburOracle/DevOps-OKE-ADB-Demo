# Identity and access parameters
api_fingerprint      = "9f:d9:eb:ce:4a:7b:cf:19:5d:67:f9:83:77:3a:42:8e"
api_private_key_path = "~/.oci/wilbur_oci_api_key.pem"

region      = "us-ashburn-1"
tenancy_ocid  = "ocid1.tenancy.oc1..aaaaaaaaro7aox2fclu4urtpgsbacnrmjv46e7n4fw3sc2wbq24l7dzf3kba"
user_ocid     = "ocid1.user.oc1..aaaaaaaanfoki42uit2xlhri3gegfwgl7ly2ua7jfnp4h5wx5eeqhlxafmgq"

# general oci parameters
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaa3zyzigwkufs5e4zks5rwtm244luxr5ztlj3ll6oznvh4dthydxnq"

vcn_name                 = "oke-us5"


# bastion
create_bastion           = false
# operator
create_operator                = false


# cluster
cluster_name       = "demo-oke-us3"
cni_type           = "flannel"
kubernetes_version = "v1.31.10"
cluster_type = "Basic"
# Worker pool defaults
worker_pool_size = 0
worker_pool_mode = "Node Pool"
worker_pool_name = "np1"

# Worker defaults
load_balancers               = "both"
preferred_load_balancer      = "public"

# ADB
db_name = "Demo-ADB-US3"
db_display_name = "Demo-ADB-US3"
db_password = "Oracle1234567"


# SSH
ssh_kms_secret_id = "ocid1.vaultsecret.oc1.iad.amaaaaaaak7gbriavxm74i3sddois3eqpholmmkeo7dncxq5s4tynzb4go5q"
ssh_kms_vault_id = "ocid1.vault.oc1.iad.ejunc4vraab4i.abuwcljrk7wkypobtsgch222zmn5m6ikjonoe4reqfrsxx534xpjogemcieq"

