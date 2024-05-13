resource "azurerm_linux_virtual_machine" "grupo5-neu-dr-web-vm" {
  name                = "webserver-dr-vm"
  resource_group_name = data.azurerm_resource_group.grupo5-neu-dr-rg.name
  location            = data.azurerm_resource_group.grupo5-neu-dr-rg.location
  #maquina barata tipo B
  size                = "Standard_B2s"
  admin_username      = "ansible"
  network_interface_ids = [azurerm_network_interface.grupo5-neu-dr-nic-web.id]
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
  offer     = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2"
  version   = "20.04.202104150"  # replace with the most recent version
}

}

resource "azurerm_network_interface" "grupo5-neu-dr-nic-web" {
  name                      = "webserver-dr-nic-web"
  location                  = data.azurerm_resource_group.grupo5-neu-dr-rg.location
  resource_group_name       = data.azurerm_resource_group.grupo5-neu-dr-rg.name

  ip_configuration {
    name                          = "webserver-dr-nic-ipconfig"
    subnet_id                     = azurerm_subnet.grupo5-neu-dr-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.1.6"
  }
}
