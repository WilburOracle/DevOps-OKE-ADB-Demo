
variable "ssh_public_key" {
  default = null
  type    = string
}
variable "ssh_kms_vault_id" {
  default = null
  type    = string
}
variable "ssh_kms_secret_id" {
  default = null
  type    = string
}




# Bastion, Operator, Workder
data "oci_secrets_secretbundle" "ssh_key" {
  secret_id = var.ssh_kms_secret_id
}

locals {
  ssh_public_key         = try(base64decode(var.ssh_public_key), var.ssh_public_key)
  ssh_key_bundle         = sensitive(one(data.oci_secrets_secretbundle.ssh_key.secret_bundle_content))
  ssh_key_bundle_content = sensitive(lookup(local.ssh_key_bundle, "content", null))
}


