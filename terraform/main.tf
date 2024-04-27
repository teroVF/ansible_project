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

#VNET DR

resource "azurerm_virtual_network" "grupo5-neu-dr-vnet" {
  name                = "grupo5-neu-dr-vnet"
  resource_group_name = azurerm_resource_group.grupo5-neu-dr-rg.name
  location            = azurerm_resource_group.grupo5-neu-dr-rg.location
  address_space       = ["192.168.1.0/24"]
}

#subnet DR

resource "azurerm_subnet" "grupo5-neu-dr-subnet" {
  name                 = "grupo5-neu-dr-subnet"
  resource_group_name  = azurerm_resource_group.grupo5-neu-dr-rg.name
  virtual_network_name = azurerm_virtual_network.grupo5-neu-dr-vnet.name
  address_prefixes     = ["192.168.1.0/24"]
}