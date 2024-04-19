# criar 3 máquinas ubuntu no azure

provider "azurerm" {
  features {}
  subscription_id = "c34f0752-7151-4ee1-ac5c-6369a3e67318"
  skip_provider_registration = true
}


# /subscriptions/c34f0752-7151-4ee1-ac5c-6369a3e67318/resourceGroups/grupo5-neu-dr-rg
# terraform import azurerm_resource_group.grupo5-neu-dr-rg /subscriptions/c34f0752-7151-4ee1-ac5c-6369a3e67318/resourceGroups/grupo5-neu-dr-rg

# {
#     "id": "/subscriptions/c34f0752-7151-4ee1-ac5c-6369a3e67318/resourceGroups/grupo5-neu-dr-rg",
#     "name": "grupo5-neu-dr-rg",
#     "type": "Microsoft.Resources/resourceGroups",
#     "location": "northeurope",
#     "tags": {},
#     "properties": {
#         "provisioningState": "Succeeded"
#     }
# }

resource "azurerm_resource_group" "grupo5-neu-dr-rg" {
  name     = "grupo5-neu-dr-rg"
  location = "North Europe"
}

# /subscriptions/c34f0752-7151-4ee1-ac5c-6369a3e67318/resourceGroups/grupo5-weu-prod-rg
# terraform import azurerm_resource_group.grupo5-weu-prod-rg /subscriptions/c34f0752-7151-4ee1-ac5c-6369a3e67318/resourceGroups/grupo5-weu-prod-rg

# {
#     "id": "/subscriptions/c34f0752-7151-4ee1-ac5c-6369a3e67318/resourceGroups/grupo5-weu-prod-rg",
#     "name": "grupo5-weu-prod-rg",
#     "type": "Microsoft.Resources/resourceGroups",
#     "location": "westeurope",
#     "tags": {},
#     "properties": {
#         "provisioningState": "Succeeded"
#     }
# }

resource "azurerm_resource_group" "grupo5-weu-prod-rg" {
  name     = "grupo5-weu-prod-rg"
  location = "West Europe"
}



# VNET PROD

resource "azurerm_virtual_network" "grupo5-weu-prod-vnet" {
  name                = "grupo5-weu-prod-vnet"
  resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name
  location            = azurerm_resource_group.grupo5-weu-prod-rg.location
  address_space       = ["192.168.0.0/24"]
  
}

#subnet PROD

resource "azurerm_subnet" "grupo5-weu-prod-subnet" {
  name                 = "grupo5-weu-prod-subnet"
  resource_group_name  = azurerm_resource_group.grupo5-weu-prod-rg.name
  virtual_network_name = azurerm_virtual_network.grupo5-weu-prod-vnet.name
  address_prefixes     = ["192.168.0.0/24"]
}

# VNET DR

# resource "azurerm_virtual_network" "grupo5-neu-dr-vnet" {
#     name                = "grupo5-neu-dr-vnet"
#     resource_group_name = azurerm_resource_group.grupo5-neu-dr-rg.name
#     location            = azurerm_resource_group.grupo5-neu-dr-rg.location
#     address_space       = ["192.168.1.0/24"]
# }

# #subnet DR

# resource "azurerm_subnet" "grupo5-neu-dr-subnet" {
#     name                 = "grupo5-neu-dr-subnet"
#     resource_group_name  = azurerm_resource_group.grupo5-neu-dr-rg.name
#     virtual_network_name = azurerm_virtual_network.grupo5-neu-dr-vnet.name
#     address_prefixes     = ["192.168.1.0/24"]
# }

#create a machine linux

resource "azurerm_linux_virtual_machine" "grupo5-weu-prod-vm" {
  name                = "grupo5-weu-prod-vm"
  resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name
  location            = azurerm_resource_group.grupo5-weu-prod-rg.location
  #maquina barata tipo B
  size                = "Standard_B1s"
  admin_username      = "admin_user"
  network_interface_ids = [azurerm_network_interface.grupo5-weu-prod-nic.id]
  #pc do antero
  admin_ssh_key {
    username   = "admin_user"
    public_key = file("./public_keys/admin.pub")
  }

  #Baixar o Script
  provisioner "file" {
    source = "./scripts/control_node.sh"
    destination = "/tmp/control_node.sh"

    connection {
      type     = "ssh"
      user     = "admin_user"
      private_key = file("./private_key/admin")
      host     = self.public_ip_address
    }
  }


  provisioner "file" {
  source = "./public_keys/antero.pub"
  destination = "/tmp/antero.pub"

    connection {
      type     = "ssh"
      user     = "admin_user"
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
      user     = "admin_user"
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
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
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
    private_ip_address = "192.168.0.5"
    public_ip_address_id          = azurerm_public_ip.grupo5-weu-prod-public-ip.id
  }
}

#public ip

resource "azurerm_public_ip" "grupo5-weu-prod-public-ip" {
  name                = "grupo5-weu-prod-public-ip"
  location            = azurerm_resource_group.grupo5-weu-prod-rg.location
  resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name
  allocation_method   = "Dynamic"
}

output "public_ip_address" {
  value = azurerm_public_ip.grupo5-weu-prod-public-ip.ip_address
}


//