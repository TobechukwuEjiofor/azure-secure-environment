data "azurerm_client_config" "current" {}

resource "random_string" "kv" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.project}-${var.environment}-${random_string.kv.result}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  tags                       = local.tags

  # Deny by default. Allowed: your IP (so Terraform can write the secret)
  # and the private subnet (so the app VM can read it).
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = [cidrhost(var.admin_cidr, 0)]
    virtual_network_subnet_ids = [azurerm_subnet.private.id]
  }
}

# You (running Terraform) may create and read secrets.
resource "azurerm_role_assignment" "admin_manages_secrets" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# The app VM may only READ secrets, using its managed identity.
resource "azurerm_role_assignment" "app_reads_secrets" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.app.identity[0].principal_id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = random_password.db.result
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_role_assignment.admin_manages_secrets]
}
