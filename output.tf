/*
output "acr_server_url" {
  value = azurerm_container_registry.acr.login_server
}
output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}
output "acr_admin_password" {
  value = azurerm_container_registry.acr.admin_password
}
output "postgress_details" {
  value = azurerm_postgresql_server.servian_postgresql_server
}
output "acr_full_details" {
  value = azurerm_container_registry.acr
}
*/

output "webapp_url" {
  value = azurerm_app_service.main.default_site_hostname
}