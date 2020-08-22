
output "resource_groupname" {
  value = azurerm_resource_group.servian_resource_group.name
}
output "postgress_details" {
  value = azurerm_postgresql_server.servian_postgresql_server
}

output "postgress_server_name" {
  value = azurerm_postgresql_server.servian_postgresql_server.name
}
output "postgress_server_url" {
  value = azurerm_postgresql_server.servian_postgresql_server.fqdn
}
output "postgress_server_username" {
  value = azurerm_postgresql_server.servian_postgresql_server.administrator_login
}
output "postgress_server_password" {
  value = azurerm_postgresql_server.servian_postgresql_server.administrator_login_password
}
output "acr_server_url" {
  value = azurerm_container_registry.servian_acr.login_server
}
output "acr_admin_username" {
  value = azurerm_container_registry.servian_acr.admin_username
}
output "acr_admin_password" {
  value = azurerm_container_registry.servian_acr.admin_password
}
output "webapp_url" {
  value = azurerm_app_service.main.default_site_hostname
}