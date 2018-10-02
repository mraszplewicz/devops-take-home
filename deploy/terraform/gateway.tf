# app services and databases should also be in virtual network - it is not available in free pricing plan
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.system_name}-${var.environment_name}-gateway-vnet"
  resource_group_name = "${var.resource_group}"
  location            = "${var.location}"
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "sub1" {
  name                 = "${var.system_name}-${var.environment_name}-gateway-subnet"
  resource_group_name  = "${var.resource_group}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.254.0.0/24"
}

resource "azurerm_public_ip" "pip" {
  name                         = "${var.system_name}-${var.environment_name}-pip"
  resource_group_name          = "${var.resource_group}"
  location                     = "${var.location}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_application_gateway" "gateway" {
  name                = "${var.system_name}-${var.environment_name}-gateway"
  resource_group_name = "${var.resource_group}"
  location            = "${var.location}"

  sku {
    name           = "Standard_Small"
    tier           = "Standard"
    capacity       = 2
  }

  gateway_ip_configuration {
    name         = "${var.system_name}-${var.environment_name}-gateway-ip-configuration"
    subnet_id    = "${azurerm_virtual_network.vnet.id}/subnets/${azurerm_subnet.sub1.name}"
  }

  frontend_port {
    name         = "${azurerm_virtual_network.vnet.name}-feport"
    port         = 80
  }

  frontend_ip_configuration {
    name         = "${azurerm_virtual_network.vnet.name}-feip"
    public_ip_address_id = "${azurerm_public_ip.pip.id}"
  }

  backend_address_pool {
    name        = "${azurerm_virtual_network.vnet.name}-backend-app-service"
    fqdn_list   = ["${azurerm_app_service.backend.name}.azurewebsites.net"]
  }

  http_listener {
    name                            = "${azurerm_virtual_network.vnet.name}-httplstn"
    frontend_ip_configuration_name  = "${azurerm_virtual_network.vnet.name}-feip"
    frontend_port_name              = "${azurerm_virtual_network.vnet.name}-feport"
    protocol                        = "Http"
  }

  backend_http_settings {
    name                  = "${azurerm_virtual_network.vnet.name}-be-htst"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    probe_name            = "${azurerm_virtual_network.vnet.name}-backend-probe"
  }

  backend_http_settings {
    name                  = "${azurerm_virtual_network.vnet.name}-frontend-htst"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    probe_name            = "${azurerm_virtual_network.vnet.name}-frontend-probe"
  }

  backend_address_pool {
    name = "${azurerm_virtual_network.vnet.name}-beap-frontend"
    fqdn_list = ["${local.frontend_static_website_fqdn}"]
  }

  request_routing_rule {
    name               = "${azurerm_virtual_network.vnet.name}-rqrt"
    rule_type          = "PathBasedRouting"
    http_listener_name = "${azurerm_virtual_network.vnet.name}-httplstn"
    url_path_map_name  = "${azurerm_virtual_network.vnet.name}-url-path-map"
  }

  url_path_map {
    name = "${azurerm_virtual_network.vnet.name}-url-path-map"
    default_backend_address_pool_name = "${azurerm_virtual_network.vnet.name}-beap-frontend"
    default_backend_http_settings_name = "${azurerm_virtual_network.vnet.name}-frontend-htst"

    path_rule {
      name = "pbr.api"
      paths = ["/api/*"]
      backend_address_pool_name = "${azurerm_virtual_network.vnet.name}-backend-app-service"
      backend_http_settings_name = "${azurerm_virtual_network.vnet.name}-be-htst"
    }
  }

# health check should be implemented in application
  probe {
    name                = "${azurerm_virtual_network.vnet.name}-backend-probe"
    protocol            = "http"
    path                = "/swagger/v1/swagger.json"
    host                = "${azurerm_app_service.backend.name}.azurewebsites.net"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }

  probe {
    name                = "${azurerm_virtual_network.vnet.name}-frontend-probe"
    protocol            = "http"
    path                = "/index.html"
    host                = "${local.frontend_static_website_fqdn}"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }
}

# workaround for not supported settings
resource "null_resource" "update_backend_http_settings_config_backend" {
  # triggers {
  #   uuid = "${uuid()}" # trigger always
  # }

  provisioner "local-exec" {
    command = "${path.module}/scripts/update-backend-http-settings-config.sh ${azurerm_application_gateway.gateway.name} ${azurerm_virtual_network.vnet.name}-be-htst"
  }
}

resource "null_resource" "update_backend_http_settings_config_frontend" {
  # triggers {
  #   uuid = "${uuid()}" # trigger always
  # }

  provisioner "local-exec" {
    command = "${path.module}/scripts/update-backend-http-settings-config.sh ${azurerm_application_gateway.gateway.name} ${azurerm_virtual_network.vnet.name}-frontend-htst"
  }

  depends_on = ["null_resource.update_backend_http_settings_config_backend"]
}