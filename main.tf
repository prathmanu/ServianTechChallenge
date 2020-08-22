provider "azurerm" {
  features {}
}
# This will create a seperate resource group for the challenge
resource "azurerm_resource_group" "servian_resource_group" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
# creating Azure postgres server Instance
resource "azurerm_postgresql_server" "servian_postgresql_server" {
  name                = "techchallenge-server-1"
  location            = azurerm_resource_group.servian_resource_group.location
  resource_group_name = azurerm_resource_group.servian_resource_group.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "postgres"
  administrator_login_password = "RealChallenge4289"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}
# adding firewall rule to give acces to azure web apps
resource "azurerm_postgresql_firewall_rule" "servian_azurerm_postgresql_firewall_rule" {
  name                = "allow_azureservices"
  resource_group_name = azurerm_resource_group.servian_resource_group.name
  server_name         = azurerm_postgresql_server.servian_postgresql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
# deploying database to the postgres server
resource "azurerm_postgresql_database" "servian_postgresql_database" {
  name                = "app"
  resource_group_name = azurerm_resource_group.servian_resource_group.name
  server_name         = azurerm_postgresql_server.servian_postgresql_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

}
#Create ACR for storing app images
resource "azurerm_container_registry" "acr" {
  name                = local.container_registry_name
  resource_group_name = azurerm_resource_group.servian_resource_group.name
  location            = azurerm_resource_group.servian_resource_group.location
  sku                 = "Standard"
  admin_enabled       = true
}

# Create appservice to serve the web app
# Create an App Service Plan with Linux
resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "${azurerm_resource_group.servian_resource_group.name}-plan"
  location            = "${azurerm_resource_group.servian_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.servian_resource_group.name}"

  # Define Linux as Host OS
  kind     = "Linux"
  reserved = true
  # Choose size
  sku {
    tier = "Standard"
    size = "S1"
  }


}

# This creates the service definition
resource "azurerm_app_service" "main" {
  name                = local.appservice_name
  location            = "${azurerm_resource_group.servian_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.servian_resource_group.name}"
  app_service_plan_id = "${azurerm_app_service_plan.appserviceplan.id}"

  site_config {
    app_command_line = "serve"
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/${var.docker_image}:${var.docker_image_tag}"

    always_on = true
  }
  identity {
    type = "SystemAssigned"
  }
  # adding all the app settings here for the web app(added DB properties as app settings so that it will override the default setting in conf.toml)
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https:///${azurerm_container_registry.acr.login_server}"
    "WEBSITES_PORT"                       = local.websites_port
    "DOCKER_REGISTRY_SERVER_USERNAME"=azurerm_container_registry.acr.admin_username
"DOCKER_REGISTRY_SERVER_PASSWORD"=azurerm_container_registry.acr.admin_password
   "VTT_DBHOST"=azurerm_postgresql_server.servian_postgresql_server.fqdn
   "VTT_DBPASSWORD"=azurerm_postgresql_server.servian_postgresql_server.administrator_login_password
   "VTT_DBUSER"="${azurerm_postgresql_server.servian_postgresql_server.administrator_login}@${azurerm_postgresql_server.servian_postgresql_server.name}"
  }
} 