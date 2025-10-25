# ---------------------------------------------------------
# PROVIDER CONFIGURATION
# ---------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.100"
    }
  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
}

# ---------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------
variable "prefix" {
  default = "demo"
}

variable "location" {
  default = "East US"
}

# ---------------------------------------------------------
# RESOURCE GROUP
# ---------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# ---------------------------------------------------------
# VIRTUAL NETWORK AND SUBNET
# ---------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ---------------------------------------------------------
# PUBLIC IP
# ---------------------------------------------------------
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# ---------------------------------------------------------
# NETWORK INTERFACE
# ---------------------------------------------------------
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# ---------------------------------------------------------
# LINUX VIRTUAL MACHINE
# ---------------------------------------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
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

  computer_name = "myvm"
  disable_password_authentication = true
}

# ---------------------------------------------------------
# OUTPUTS
# ---------------------------------------------------------
output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}
