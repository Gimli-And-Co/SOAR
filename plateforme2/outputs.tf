output "app_service_name" {
  value = flatten([[azurerm_app_service.frontend_ressource.*.name], [azurerm_app_service.keycloak_ressource.name], [azurerm_app_service.backend_ressource.*.name]])
}

# output "app_service_default_hostname" {
#   value = flatten([["https://${azurerm_app_service.frontend_ressource.*.default_site_hostname}"], ["https://${azurerm_app_service.keycloak_ressource.default_site_hostname}"], ["https://${azurerm_app_service.backend_ressource.*.default_site_hostname}"]])
# }
