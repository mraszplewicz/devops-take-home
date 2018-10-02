resource "azurerm_sql_database" "db" {
  name                             = "devops-db"
  resource_group_name              = "${var.resource_group}"
  location                         = "${var.location}"
  server_name                      = "${azurerm_sql_server.server.name}"
}

resource "azurerm_sql_server" "server" {
  name                         = "${var.system_name}-${var.environment_name}-sqlsvr"
  resource_group_name          = "${var.resource_group}"
  location                     = "${var.location}"
  version                      = "12.0"
  administrator_login          = "${var.sql_admin}"
  administrator_login_password = "${var.sql_password}"
}

# Enables the "Allow Access to Azure services" box as described in the API docs 
# https://docs.microsoft.com/en-us/rest/api/sql/firewallrules/createorupdate
resource "azurerm_sql_firewall_rule" "fw" {
  name                = "firewallrules"
  resource_group_name = "${var.resource_group}"
  server_name         = "${azurerm_sql_server.server.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# in a real world application database initialization should be done by schema migrations
resource "null_resource" "database_init" {
  # triggers {
  #   uuid = "${uuid()}" # trigger always
  # }

  provisioner "local-exec" {
    command = "${path.module}/scripts/database-init.sh ${azurerm_sql_server.server.name} ${azurerm_sql_server.server.fully_qualified_domain_name} 1433 ${azurerm_sql_database.db.name} ${var.sql_admin} ${var.sql_password}"
  }
}