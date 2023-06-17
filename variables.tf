variable "su_username" {
  type        = string
  description = "SoftUni username"
}

variable "resource_group_name" {
  type        = string
  description = "Resource name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "Location of RG in Azure"
}

variable "app_service_plan_name" {
  type        = string
  description = "App plan name"
}

variable "app_service_plan" {
  type = string
}
variable "sql_server_name" {
  type = string
}
variable "sql_database_name" {
  type = string
}
variable "sql_admin_login" {
  type = string
}
variable "sql_admin_password" {
  type = string
}
variable "firewall_rule_name" {
  type = string
}
variable "repo_URL" {
  type = string
}