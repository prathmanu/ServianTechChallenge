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
  ssl_enforcement_enabled      = false
}
# deploying database to the postgres server
resource "azurerm_postgresql_database" "servian_postgresql_database" {
  name                = "postgres1"
  resource_group_name = azurerm_resource_group.servian_resource_group.name
  server_name         = azurerm_postgresql_server.servian_postgresql_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}