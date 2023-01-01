# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}


# Configure the Azure Provider
provider "azurerm" {
  subscription_id = "XXXXXXXXXXXXXXXXXXXXXXXXX"
  client_id = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  client_secret = "XXXXXXXXXXXXXXXXXXXXX"
  tenant_id = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx"
#  version = "2.70.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "my_rg" {
  name = "${var.resource_prefix}-RG"
  location = var.location
  tags     = "${var.tags}"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example_vnet" {
  name = "${var.resource_prefix}-vnet"
  resource_group_name = azurerm_resource_group.my_rg.name
  location = var.location
  address_space = var.node_address_space
  tags     = "${var.tags}"
}

# Create a subnets within the virtual network
resource "azurerm_subnet" "example_subnet" {
  name = "${var.resource_prefix}-subnet"
  resource_group_name = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes = var.node_address_prefix
}

# Create Linux Public IP
resource "azurerm_public_ip" "example_public_ip" {
  count = var.node_count
  name = "${var.resource_prefix}-${format("%02d", count.index)}-PublicIP"
  #name = "${var.resource_prefix}-PublicIP"
  location = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  allocation_method = "${var.public_ip_address_allocation}"
  tags     = "${var.tags}"
}

# Create Network Interface
resource "azurerm_network_interface" "example_nic" {
  count = var.node_count
  #name = "${var.resource_prefix}-NIC"
  name = "${var.resource_prefix}-${format("%02d", count.index)}-NIC"
  location = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = element(azurerm_public_ip.example_public_ip.*.id, count.index)
    #public_ip_address_id = azurerm_public_ip.example_public_ip.id
    #public_ip_address_id = azurerm_public_ip.example_public_ip.id
  }
  tags     = "${var.tags}"
}

# Creating resource NSG
resource "azurerm_network_security_group" "example_nsg" {
  name = "${var.resource_prefix}-NSG"
  location = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

# Security rule can also be defined with resource azurerm_network_security_rule, here just defining it inline.
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    }
  tags     = "${var.tags}"
}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "example_subnet_nsg_association" {
  subnet_id = azurerm_subnet.example_subnet.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}

# Virtual Machine Creation — Linux
resource "azurerm_virtual_machine" "terraform_linux_vm" {
  count = var.node_count
  name = "${var.resource_prefix}-${format("%02d", count.index)}"
  #name = "${var.resource_prefix}-VM"
  location = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  network_interface_ids = [element(azurerm_network_interface.terraform_nic.*.id, count.index)]
  vm_size = "${var.vm_size}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "RedHat"
    offer = "RHEL"
    sku = "8-LVM"
    version = "latest"
  }
  storage_os_disk {
    name = "myosdisk-${count.index}"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name = var.hostname[count.index]
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  provisioner "file" {
  source      = "templates/initial_setup.sh"
  destination = "/tmp/initial_setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/initial_setup.sh",
      "/tmp/initial_setup.sh var.resource_prefix var.hostname[count.index]",
    ]
  }
  connection {
      type     = "ssh"
      user     = "${var.admin_username}"
      password = "${var.admin_password}"
      host     = azurerm_network_interface.terraform_nic[count.index].private_ip_address
  }
tags     = "${var.tags}"
}