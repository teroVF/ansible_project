resource "azurerm_linux_virtual_machine" "grupo5-weu-prod-web-vm" {
  name                = "webserver-linux"
  resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name
  location            = azurerm_resource_group.grupo5-weu-prod-rg.location
  #maquina barata tipo B
  size                = "Standard_B2s"
  admin_username      = "ansible"
  network_interface_ids = [azurerm_network_interface.grupo5-weu-prod-nic-web.id]
  admin_ssh_key {
    username   = "ansible"
    public_key = file("./public_keys/ansible.pub")
  }

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

}

resource "azurerm_network_interface" "grupo5-weu-prod-nic-web" {
  name                      = "grupo5-weu-prod-nic-web"
  location                  = azurerm_resource_group.grupo5-weu-prod-rg.location
  resource_group_name       = azurerm_resource_group.grupo5-weu-prod-rg.name

  ip_configuration {
    name                          = "grupo5-weu-prod-nic-ipconfig"
    subnet_id                     = azurerm_subnet.grupo5-weu-prod-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.0.6"
  }
}
