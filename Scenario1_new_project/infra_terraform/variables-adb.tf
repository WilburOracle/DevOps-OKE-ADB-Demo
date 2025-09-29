# ADB specific
variable "db_version" {
  type    = string
  default = "19c"
}
variable "db_name" {
  type    = string
  default = "DemoADB"
}
variable "db_display_name" {
  type    = string
  default = "Demo-ADB"
}
variable "db_workload" {
  type    = string
  default = "DW"
}
variable "db_compute_count" {
  type    = number
  default = 1
}
variable "db_data_storage_size_in_tbs" {
  type    = number
  default = 1
}
variable "db_compute_model" {
  type    = string
  default = "ECPU"
}
variable "db_is_dedicated" {
  type    = string
  default = "false"
}
variable "db_is_mtls_connection_required" {
  type    = string
  default = "false"
}
variable "db_license_model" {
  type    = string
  default = "BRING_YOUR_OWN_LICENSE"
}
variable "db_is_data_guard_enabled" {
  type    = string
  default = "false"
}
variable "db_is_local_data_guard_enabled" {
  type    = string
  default = "false"
}
variable "db_password" {
  type      = string
  sensitive = false
  default   = "Oracle1234567"
}