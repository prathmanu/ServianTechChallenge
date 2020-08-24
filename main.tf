provider "azurerm" {
  features {}
}
# This will create a seperate resource group for the challenge
resource "azurerm_resource_group" "servian_resource_group" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

#End of Resource Group Creation. Created Resource group and saved name in key vault
#-----------------------------------------------------------------------------------------------

# Start of Postgres Deployment

resource "random_string" "password" {
  length  = 16
  special = true
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

  administrator_login          = var.username
  administrator_login_password = "${random_string.password.result}"
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

#End of Postgres Deployment
#-------------------------------------------------------------------------------------------------------------------------

# Strat of ACR deployment
#Create ACR for storing app images
resource "azurerm_container_registry" "servian_acr" {
  name                = local.container_registry_name
  resource_group_name = azurerm_resource_group.servian_resource_group.name
  location            = azurerm_resource_group.servian_resource_group.location
  sku                 = "Standard"
  admin_enabled       = true
}

#End of ACR deployment
#--------------------------------------------------------------------------------------------------------------------------

# Start of App Service Deployment
# Create appservice to serve the web app
# Create an App Service Plan with Linux
resource "azurerm_app_service_plan" "servian_appserviceplan" {
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
  app_service_plan_id = "${azurerm_app_service_plan.servian_appserviceplan.id}"

  site_config {
    app_command_line = "serve"
    linux_fx_version = "DOCKER|${azurerm_container_registry.servian_acr.login_server}/${var.docker_image}:${var.docker_image_tag}"

    always_on = true
  }
  identity {
    type = "SystemAssigned"
  }
  # adding all the app settings here for the web app(added DB properties as app settings so that it will override the default setting in conf.toml)
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https:///${azurerm_container_registry.servian_acr.login_server}"
    "WEBSITES_PORT"                       = local.websites_port
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.servian_acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.servian_acr.admin_password
    "VTT_DBHOST"                          = azurerm_postgresql_server.servian_postgresql_server.fqdn
    "VTT_DBPASSWORD"                      = azurerm_postgresql_server.servian_postgresql_server.administrator_login_password
    "VTT_DBUSER"                          = "${azurerm_postgresql_server.servian_postgresql_server.administrator_login}@${azurerm_postgresql_server.servian_postgresql_server.name}"
    "VTT_LISTENHOST"                      = "0.0.0.0"
  }
}

# End of App sservice deployment


#-------------------------------------------------------------------------------------------------------------------------------

# Start of Key vault Deployment
# Adding Key vault to save sensitive infrastructure details
# Create the Azure Key Vault
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "key-vault" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = var.sku_name
  tags      = var.tags

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
  depends_on = [
    azurerm_resource_group.servian_resource_group
  ]
}

# Create a Default Azure Key Vault access policy with Admin permissions
# This policy must be kept for a proper run of the "destroy" process(Only key and secret permission required for this usecase)
resource "azurerm_key_vault_access_policy" "default_policy" {
  key_vault_id = azurerm_key_vault.key-vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  lifecycle {
    create_before_destroy = true
  }

  key_permissions         = var.kv-key-permissions-full
  secret_permissions      = var.kv-secret-permissions-full
  certificate_permissions = var.kv-certificate-permissions-full
  storage_permissions     = var.kv-storage-permissions-full
}

# Create an Azure Key Vault access policy
resource "azurerm_key_vault_access_policy" "policy" {
  for_each                = var.policies
  key_vault_id            = azurerm_key_vault.key-vault.id
  tenant_id               = lookup(each.value, "tenant_id")
  object_id               = lookup(each.value, "object_id")
  key_permissions         = lookup(each.value, "key_permissions")
  secret_permissions      = lookup(each.value, "secret_permissions")
  certificate_permissions = lookup(each.value, "certificate_permissions")
  storage_permissions     = lookup(each.value, "storage_permissions")
}


#------------------------------------------------------------------------------------------------------------------

# Start of key secret store for infra details(Can be done in a single step using map of objects using a tfvar file)

resource "azurerm_key_vault_secret" "resourcegroup" {

  key_vault_id = azurerm_key_vault.key-vault.id
  name         = "ResourceGroupName"
  value        = azurerm_resource_group.servian_resource_group.name
  tags         = var.tags
  depends_on = [
    azurerm_key_vault.key-vault,
    azurerm_key_vault_access_policy.default_policy,
  ]
}

resource "azurerm_key_vault_secret" "postgresServerName" {

  key_vault_id = azurerm_key_vault.key-vault.id
  name         = "postgresServerName"
  value        = azurerm_postgresql_server.servian_postgresql_server.name
  tags         = var.tags
  depends_on = [
    azurerm_key_vault.key-vault,
    azurerm_key_vault_access_policy.default_policy,
  ]
}
resource "azurerm_key_vault_secret" "postgresServerUrl" {

  key_vault_id = azurerm_key_vault.key-vault.id
  name         = "postgresServerUrl"
  value        = azurerm_postgresql_server.servian_postgresql_server.fqdn
  tags         = var.tags
  depends_on = [
    azurerm_key_vault.key-vault,
    azurerm_key_vault_access_policy.default_policy,
  ]
}
resource "azurerm_key_vault_secret" "postgresServerUsername" {

  key_vault_id = azurerm_key_vault.key-vault.id
  name         = "postgresServerUsername"
  value        = azurerm_postgresql_server.servian_postgresql_server.administrator_login
  tags         = var.tags
  depends_on = [
    azurerm_key_vault.key-vault,
    azurerm_key_vault_access_policy.default_policy,
  ]
}
resource "azurerm_key_vault_secret" "postgresServerPassword" {

  key_vault_id = azurerm_key_vault.key-vault.id
  name         = "postgresServerPassword"
  value        = azurerm_postgresql_server.servian_postgresql_server.administrator_login_password
  tags         = var.tags
  depends_on = [
    azurerm_key_vault.key-vault,
    azurerm_key_vault_access_policy.default_policy,
  ]
}
resource "azurerm_key_vault_secret" "AcrServerUrl" {

  key_vault_id = azurerm_key_vault.key-vault.id
  name         = "AcrServerUrl"
  value        = azurerm_container_registry.servian_acr.login_server
  tags         = var.tags
  depends_on = [
    azurerm_key_vault.key-vault,
    azurerm_key_vault_access_policy.default_policy,
  ]
}
resource "azurerm_key_vault_secret" "AcrAdminUsername" {

  key_vault_id = azurerm_key_vault.key-vault.id
  name         = "AcrAdminUsername"
  value        = azurerm_container_registry.servian_acr.admin_username
  tags         = var.tags
  depends_on = [
    azurerm_key_vault.key-vault,
    azurerm_key_vault_access_policy.default_policy,
  ]
}
resource "azurerm_key_vault_secret" "AcrAdminPassword" {

  key_vault_id = azurerm_key_vault.key-vault.id
  name         = "AcrAdminPassword"
  value        = azurerm_container_registry.servian_acr.admin_password
  tags         = var.tags
  depends_on = [
    azurerm_key_vault.key-vault,
    azurerm_key_vault_access_policy.default_policy,
  ]
}
#-----------------------------------------------------------------------------------------------------