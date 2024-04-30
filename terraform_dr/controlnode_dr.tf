resource "azurerm_linux_virtual_machine" "grupo5-neu-dr-vm" {
  depends_on = [azurerm_linux_virtual_machine.grupo5-neu-dr-db-vm, azurerm_linux_virtual_machine.grupo5-neu-dr-web-vm]
  name               = "controlnode-dr-vm"
  resource_group_name = data.azurerm_resource_group.grupo5-neu-dr-rg.name
  location            = data.azurerm_resource_group.grupo5-neu-dr-rg.location
  #maquina barata tipo B
  size                = "Standard_B2s"
  admin_username      = "ansible"
  network_interface_ids = [azurerm_network_interface.grupo5-neu-dr-nic.id]
  admin_ssh_key {
    username   = "ansible"
    public_key = file("./public_keys/admin.pub")
  }

# ansible directory
  provisioner "file" {
    source = "ansible_cn"
    destination = "/tmp/ansible/"

    connection {
      type     = "ssh"
      user     = "ansible"
      private_key = file("./private_key/admin")
      host     = self.public_ip_address
    }
  }
#Baixar a chave privada para os managed nodes
  provisioner "file" {
    source = "private_key/ansible"
    destination = "/tmp/ansible.pem"

    connection {
      type     = "ssh"
      user     = "ansible"
      private_key = file("./private_key/admin")
      host     = self.public_ip_address
    }
  }

  provisioner "file" {
    source = "scripts/control_node.sh"
    destination = "/tmp/control_node.sh"

    connection {
      type     = "ssh"
      user    = "ansible"
      private_key = file("./private_key/admin")
      host     = self.public_ip_address
    }
  }



#public keys dos utilizadores
  provisioner "file" {
  source = "public_keys"
  destination = "/tmp/public_keys"

    connection {
      type     = "ssh"
      user     = "ansible"
      private_key = file("./private_key/admin")
      host     = self.public_ip_address
    }
  }
  
  #Execução do script
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/control_node.sh",
      "sudo /tmp/control_node.sh"
    ]

    connection {
      type     = "ssh"
      user     = "ansible"
      private_key = file("./private_key/admin")
      host     = self.public_ip_address
    }
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

resource "azurerm_network_interface" "grupo5-neu-dr-nic" {
  name                      = "controlnode-dr-nic"
  location                  = data.azurerm_resource_group.grupo5-neu-dr-rg.location
  resource_group_name       = data.azurerm_resource_group.grupo5-neu-dr-rg.name

  ip_configuration {
    name                          = "controlnode-dr-nic-ipconfig"
    subnet_id                     = azurerm_subnet.grupo5-neu-dr-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.1.101"
    public_ip_address_id          = azurerm_public_ip.grupo5-neu-dr-public-ip.id
  }
}

#public ip

resource "azurerm_public_ip" "grupo5-neu-dr-public-ip" {
  name                = "controlnode-dr-public-ip"
  location            = data.azurerm_resource_group.grupo5-neu-dr-rg.location
  resource_group_name = data.azurerm_resource_group.grupo5-neu-dr-rg.name
  allocation_method   = "Static"
}

output "public_ip_address" {
  value = azurerm_public_ip.grupo5-neu-dr-public-ip.ip_address
}