variable "resource_group" {
  description = "The name of the resource group in which to create all resources."
}

variable "location" {
  description = "The location/region where all resources will be created. Changing this forces a new resource to be created."
}

variable "system_name" {
    description = "The name of the system to be deployed."
}

variable "environment_name" {
    description = "The name of the system's environment."
}

variable "sql_admin" {
    default = "adm"
    description = "The administrator username of the SQL Server."
}

variable "sql_password" {
    default = "test123$%^"
    description = "The administrator password of the SQL Server. In real world should be generated and stored in e.g. vault"
}

variable "backend_app_service_plan_sku_tier" {
  description = "SKU tier of the Backend App Service Plan"
  default     = "Basic"
}

variable "backend_app_service_plan_sku_size" {
  description = "SKU size of the Backend App Service Plan"
  default     = "B1"
}

output "app_url" {
  description = "Public url of deployed application"
  value = "http://${data.azurerm_public_ip.gateway_ip.ip_address}/"
}
