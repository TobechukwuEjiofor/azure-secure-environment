output "bastion_public_ip" {
  value = azurerm_public_ip.bastion.ip_address
}

output "app_private_ip" {
  value = azurerm_network_interface.app.private_ip_address
}

output "lb_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}

output "db_name" {
  value = azurerm_postgresql_flexible_server.main.name
}

output "db_fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}

output "kv_name" {
  value = azurerm_key_vault.main.name
}
