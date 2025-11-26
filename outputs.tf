output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "ingress_public_ip" {
  value = azurerm_public_ip.ingress.ip_address
}

output "location" {
  value = var.location
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

