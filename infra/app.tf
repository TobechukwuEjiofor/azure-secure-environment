resource "azurerm_network_interface" "app" {
  name                = "nic-${var.project}-${var.environment}-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  name                  = "vm-${var.project}-${var.environment}-app"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.vm_size
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.app.id]
  tags                  = local.tags

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOT
    #!/bin/bash
    for i in 1 2 3 4 5 6; do
      apt-get -o DPkg::Lock::Timeout=120 update && break
      sleep 10
    done
    apt-get -o DPkg::Lock::Timeout=120 install -y nginx
    echo "<h1>Bridgeline Pay</h1><p>Served by $(hostname)</p>" > /var/www/html/index.html
    systemctl enable --now nginx
  EOT
  )

  depends_on = [
    azurerm_network_interface_backend_address_pool_association.app,
    azurerm_lb_outbound_rule.app,
  ]
}
