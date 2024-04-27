resource "azurerm_linux_virtual_machine" "grupo5-weu-prod-vm" {
  depends_on = [azurerm_linux_virtual_machine.grupo5-weu-prod-db-vm, azurerm_linux_virtual_machine.grupo5-weu-prod-web-vm]
  name                = "controlnode-prod-vm"
  resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name
  location            = azurerm_resource_group.grupo5-weu-prod-rg.location
  #maquina barata tipo B
  size                = "Standard_B2s"
  admin_username      = "ansible"
  network_interface_ids = [azurerm_network_interface.grupo5-weu-prod-nic.id]
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

resource "azurerm_network_interface" "grupo5-weu-prod-nic" {
  name                      = "grupo5-weu-prod-nic"
  location                  = azurerm_resource_group.grupo5-weu-prod-rg.location
  resource_group_name       = azurerm_resource_group.grupo5-weu-prod-rg.name

  ip_configuration {
    name                          = "grupo5-weu-prod-nic-ipconfig"
    subnet_id                     = azurerm_subnet.grupo5-weu-prod-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.0.101"
    public_ip_address_id          = azurerm_public_ip.grupo5-weu-prod-public-ip.id
  }
}

#public ip

resource "azurerm_public_ip" "grupo5-weu-prod-public-ip" {
  name                = "grupo5-weu-prod-public-ip"
  location            = azurerm_resource_group.grupo5-weu-prod-rg.location
  resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name
  allocation_method   = "Static"
}

output "public_ip_address" {
  value = azurerm_public_ip.grupo5-weu-prod-public-ip.ip_address
}