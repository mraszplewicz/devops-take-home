locals {
    storage_account_name = "${substr(replace(var.system_name, "-", ""), 0, 15)}${replace(var.environment_name, "-", "")}f"
}

resource "azurerm_storage_account" "frontendstorage" {
  name                     = "${local.storage_account_name}"
  resource_group_name      = "${var.resource_group}"
  location                 = "${var.location}"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "archive_file" "frontend" {
  type        = "zip"
  source_dir  = "/src/frontend"
  output_path = "/frontend.zip"
}

resource "null_resource" "frontend_deploy" {
  triggers {
    # uuid = "${uuid()}" # trigger always
    frontend_zip = "${data.archive_file.frontend.output_md5}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/frontend-deploy.sh ${azurerm_storage_account.frontendstorage.name}"
  }
}

data "external" "frontend_static_website_url" {
  program = ["bash", "${path.module}/scripts/get-static-website-url.sh"]

  query = {
    storage_account = "${azurerm_storage_account.frontendstorage.name}"
  }

  depends_on = ["null_resource.frontend_deploy"]
}

locals {
    frontend_static_website_url = "${lookup(data.external.frontend_static_website_url.result, "url")}"
    frontend_static_website_fqdn = "${substr(local.frontend_static_website_url, 8, length(local.frontend_static_website_url)-9)}"
}
