#window machine azure windows server 2022 winrm
data "template_file_dr" "init" {
  template = file("./scripts/window_script.ps1")
}


resource "azurerm_windows_virtual_machine" "windows-dr" {
    depends_on = [ azurerm_network_interface.nic, azurerm_public_ip.publicip, azurerm_network_interface_security_group_association.example]
    name                  = "windows-dr-vm"
    resource_group_name   = azurerm_resource_group.grupo5-neu-dr-rg.name
    location              = azurerm_resource_group.grupo5-neu-dr-rg.location
    size                  = "Standard_B2s"
    admin_username        = "ansible"
    admin_password        = var.admin_password
    network_interface_ids = [azurerm_network_interface.nic.id]

    provision_vm_agent = "true" 
    winrm_listener {
      protocol = "Http" 
    }
    custom_data = base64encode(data.template_file.init.rendered)
    additional_unattend_content {
      setting      = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>ansible</Username></AutoLogon>"
   }

    additional_unattend_content {
      setting      = "FirstLogonCommands"
      content      = "${file("./scripts/firstlogoncommands.xml")}"
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

resource "azurerm_network_interface" "nic-dr" {
    name                = "windows-dr-nic"
    location            = azurerm_resource_group.grupo5-neu-dr-rg.location
    resource_group_name = azurerm_resource_group.grupo5-neu-dr-rg.name

    ip_configuration {
        name                          = "windows-dr-nic-ipconfig"
        subnet_id                     = azurerm_subnet.grupo5-neu-dr-subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "192.168.1.100"
        public_ip_address_id = azurerm_public_ip.publicip.id
    }
}

#public ip

resource "azurerm_public_ip" "publicip-dr" {
    name                = "publicip"
    location            = azurerm_resource_group.grupo5-neu-dr-rg.location
    resource_group_name = azurerm_resource_group.grupo5-neu-dr-rg.name
    allocation_method   = "Static"
}



#nsg windows

resource "azurerm_network_security_group" "windows_nsg-dr" {
  name                = "windows-dr-nsg"
  location            = azurerm_resource_group.grupo5-neu-dr-rg.location 
  resource_group_name = azurerm_resource_group.grupo5-neu-dr-rg.name

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

resource "azurerm_network_interface_security_group_association" "example-dr" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.windows_nsg.id
}

#https://stackoverflow.com/questions/69390742/terraform-windows-server-2016-adding-and-running-scripts-using-winery