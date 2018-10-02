resource "azurerm_app_service_plan" "backend" {
  name                = "${var.system_name}-${var.environment_name}-backend-plan"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  kind                = "Linux"

  sku {
    tier = "${var.backend_app_service_plan_sku_tier}"
    size = "${var.backend_app_service_plan_sku_size}"
  }

  properties {
    reserved = true
  }
}

resource "azurerm_app_service" "backend" {
  name                = "${var.system_name}-${var.environment_name}-backend"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  app_service_plan_id = "${azurerm_app_service_plan.backend.id}"

  site_config {
    linux_fx_version = "DOTNETCORE|2.0"
    ftps_state = "Disabled"
  }

  connection_string {
    name  = "Db"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.server.fully_qualified_domain_name},1433;Database=${azurerm_sql_database.db.name};User ID=${var.sql_admin};Password=${var.sql_password};Encrypt=true;Connection Timeout=30;"
  }
}

data "archive_file" "backend" {
  type        = "zip"
  source_dir  = "/build"
  output_path = "/build.zip"
}

resource "null_resource" "backend_deploy" {
  triggers {
    # uuid = "${uuid()}" # trigger always
    backend_zip = "${data.archive_file.backend.output_md5}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/backend-deploy.sh ${azurerm_app_service.backend.name}"
  }
}