#*************************************
#           TF Requirements
#*************************************
variable "region" {
  description = "OCI Region"
  default = "ap-tokyo-1"
  nullable    = false
}

variable "tenancy_ocid" {
  description = "Tenancy OCID"
  nullable    = false
}

variable "compartment_ocid" {
  description = "OCID of the compartment where VCN, Compute and Opensearch will be created"
  nullable    = false
}

variable "user_ocid" {
  description = "OCID of the user who provisioning OCI resources"
  default     = ""
}

variable "api_private_key_path" {
  default = ""
}

variable "api_fingerprint" {
  default = ""
}
