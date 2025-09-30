resource "oci_database_autonomous_database" "tf_database_autonomous_database" {
       admin_password = var.db_password
       compartment_id = var.compartment_ocid
       compute_count = var.db_compute_count
       compute_model = var.db_compute_model
       data_storage_size_in_tbs = var.db_data_storage_size_in_tbs
       db_name = var.db_name
       db_version = var.db_version
       db_workload = var.db_workload
       display_name = var.db_display_name
       is_dedicated = var.db_is_dedicated
       is_mtls_connection_required = var.db_is_mtls_connection_required
       license_model = var.db_license_model
       whitelisted_ips = ["0.0.0.0/0"]
       is_data_guard_enabled = var.db_is_data_guard_enabled
       is_local_data_guard_enabled = var.db_is_local_data_guard_enabled
}

locals {
  adb_dsn = [for p in oci_database_autonomous_database.tf_database_autonomous_database.connection_strings[0].profiles : p.value if p.consumer_group == "HIGH" && p.tls_authentication == "MUTUAL"][0]
  adb_conn_str = oci_database_autonomous_database.tf_database_autonomous_database.connection_strings[0].high
  # adb_conn_str的值是 adb.us-ashburn-1.oraclecloud.com:1522/n7djxxqbnkflnvn_demoadbus3_high.adb.oraclecloud.com
  adb_host = split(":", local.adb_conn_str)[0]
  adb_service_name = split("/", local.adb_conn_str)[1]
}
# 在ADB创建成功后执行初始化脚本
resource "null_resource" "adb_initialization" {
  depends_on = [oci_database_autonomous_database.tf_database_autonomous_database]

  provisioner "local-exec" {
    command = <<EOT
      sql 'admin/Oracle1234567@${local.adb_dsn}' @init/adb-init.sql
    EOT
  }
}

# Outputs

output "db_display_name" {
  value = oci_database_autonomous_database.tf_database_autonomous_database.display_name
}
output "db_state" {
  value = oci_database_autonomous_database.tf_database_autonomous_database.state
}
output "db_conn" {
  value = oci_database_autonomous_database.tf_database_autonomous_database.connection_urls
}
output "adb_dsn" {
  value = local.adb_dsn
}

output "adb_host" {
  value = local.adb_host
}

output "adb_service_name" {
  value = local.adb_service_name
}

