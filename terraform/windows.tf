#window machine azure windows server 2022 winrm
data "template_file" "init" {
  template = file("./scripts/window_script.ps1")
}


resource "azurerm_windows_virtual_machine" "windows" {
    depends_on = [ azurerm_network_interface.nic, azurerm_public_ip.publicip, azurerm_network_interface_security_group_association.example]
    name                  = "windows"
    resource_group_name   = azurerm_resource_group.grupo5-weu-prod-rg.name
    location              = azurerm_resource_group.grupo5-weu-prod-rg.location
    size                  = "Standard_B1s"
    admin_username        = "ansible"
    admin_password        = "Password1234!"
    network_interface_ids = [azurerm_network_interface.nic.id]
    custom_data = base64encode(data.template_file.init.rendered)
    additional_unattend_content {
      setting      = "AutoLogon"
      content      = "<AutoLogon><Password><Value>Password1234!</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>ansible</Username></AutoLogon>"
   }

    additional_unattend_content {
      setting      = "FirstLogonCommands"
      content      = "${file("./scripts/firstlogoncommands.xml")}"
    }

    provision_vm_agent = "true" 
    winrm_listener {
      protocol = "Http" 
    }

    # provisioner "remote-exec" {
    #     inline = ["winrm qc"]

    #     connection {
    #         type     = "winrm"
    #         user     = "ansible"
    #         password = "Password1234!"
    #         host     = self.public_ip_address
    #         timeout  = "5m"
    #         port     = 5985
    #         https    = false
    #     }
    # }

    provisioner "file" {
        
        source      = "./scripts/window_script.ps1"
        destination = "C:/Users/ansible/Desktop/window_script.ps1"

        connection {
            type     = "winrm"
            user     = "ansible"
            password = "Password1234!"
            host     = self.public_ip_address
            timeout = "5m"
            port = 5985
            https = false
        }
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-Datacenter"
        version   = "latest"
    }
}

resource "azurerm_network_interface" "nic" {
    name                = "nic"
    location            = azurerm_resource_group.grupo5-weu-prod-rg.location
    resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name

    ip_configuration {
        name                          = "ipconfig"
        subnet_id                     = azurerm_subnet.grupo5-weu-prod-subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "192.168.0.100"
        public_ip_address_id = azurerm_public_ip.publicip.id
    }
}

#public ip

resource "azurerm_public_ip" "publicip" {
    name                = "publicip"
    location            = azurerm_resource_group.grupo5-weu-prod-rg.location
    resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name
    allocation_method   = "Static"
}



#nsg windows

resource "azurerm_network_security_group" "windows_nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.grupo5-weu-prod-rg.location 
  resource_group_name = azurerm_resource_group.grupo5-weu-prod-rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "WinRM"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.windows_nsg.id
}

#https://stackoverflow.com/questions/69390742/terraform-windows-server-2016-adding-and-running-scripts-using-winery