locals {
  tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}-${var.environment}"
  location = var.location
  tags     = local.tags
}
