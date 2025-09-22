# Terraform configuration for OCI DevOps-OKE-ADB Demo - Scene 3 (New Region)

provider "oci" {
  region = var.region
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
}

# Common variables
variable "region" {
  description = "OCI region for the new deployment"
  type = string
}

variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type = string
}

variable "user_ocid" {
  description = "OCID of the user"
  type = string
}

variable "fingerprint" {
  description = "Fingerprint for the user's API key"
  type = string
}

variable "private_key_path" {
  description = "Path to the private key file"
  type = string
}

variable "image_name" {
  description = "Container image name to deploy"
  type = string
}

# ADB Configuration with both init and release SQL
module "autonomous_database" {
  source = "oracle-terraform-modules/autonomous-database/oci"
  # Module configuration will be added here
}

# SQL Scripts Application
resource "null_resource" "apply_init_sql" {
  # Configuration to apply initialization SQL file
}

resource "null_resource" "apply_release_sql" {
  # Configuration to apply release version SQL file
}

# OKE Cluster Configuration
module "oke_cluster" {
  source = "oracle-terraform-modules/oke/oci"
  # Module configuration will be added here
}

# DevOps Configuration
module "devops_project" {
  source = "oracle-terraform-modules/devops/oci"
  # Module configuration will be added here
}

# Container Deployment
resource "null_resource" "deploy_container" {
  # Configuration to deploy container image to OKE
}

# Outputs
output "adb_connection_string" {
  value = module.autonomous_database.db_connection_string
}

output "oke_cluster_id" {
  value = module.oke_cluster.cluster_id
}

output "devops_project_id" {
  value = module.devops_project.project_id
}