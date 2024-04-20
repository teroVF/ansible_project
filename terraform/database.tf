resource "azurerm_network_interface" "grupo5-weu-prod-nic-db" {
    name                = "grupo5-weu-prod-nic-db"
    location            = azurerm_resource_group.grupo5-weu-prod-rg.location
    resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name

    ip_configuration {
        name                          = "my-ip-configuration"
        subnet_id                     = azurerm_subnet.grupo5-weu-prod-subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "192.168.0.7"
    }
}

resource "azurerm_linux_virtual_machine" "grupo5-weu-prod-db-vm" {
    name                = "grupo5-weu-prod-db-vm"
    location            = azurerm_resource_group.grupo5-weu-prod-rg.location
    resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name
    size                = "Standard_DS2_v2"
    admin_username      = "ansible"
    network_interface_ids = [
        azurerm_network_interface.grupo5-weu-prod-nic-db.id,
    ]

    admin_ssh_key {
    username   = "ansible"
    public_key = file("./public_keys/admin.pub")
  }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    custom_data = base64encode(<<EOF
#!/bin/bash
apt-get update
apt-get install -y mysql-server
EOF
    )
}