# L11 Exam preparation
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.59.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# This will be needed to create uniqe names bellow
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.su_username}${var.resource_group_name}-${random_integer.ri.result}"
  location = resource_group_location
}

# Create service plan
resource "azurerm_service_plan" "sp" {
  name                = "${app_service_plan_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

# Define web app
resource "azurerm_linux_web_app" "task_board_app" {
  name                = "${app_service_plan}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.sp.id
  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sql.name};User ID=${azurerm_mssql_server.sqlserver.administrator_login};Password=${azurerm_mssql_server.sqlserver.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

# Create the SQL server
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "${sql_server_name}-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = sql_admin_login
  administrator_login_password = sql_admin_password
}

# Create database
resource "azurerm_mssql_database" "sql" {
  name         = "${sql_database_name}-${random_integer.ri.result}"
  server_id    = azurerm_mssql_server.sqlserver.id
  license_type = "LicenseIncluded"
  sku_name     = "S0"
}

# Set firewall rule
resource "azurerm_mssql_firewall_rule" "sql_firewall" {
  name             = "${firewall_rule_name}-${random_integer.ri.result}"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Set source for code
resource "azurerm_app_service_source_control" "git" {
  app_id                 = azurerm_linux_web_app.task_board_app.id
  repo_url               = repo_URL
  branch                 = "main"
  use_manual_integration = true
}
