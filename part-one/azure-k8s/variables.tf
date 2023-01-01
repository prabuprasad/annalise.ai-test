variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  type = string
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  type = string
}

variable "node_address_space" {
default = ["10.11.0.0/16"]
}

variable "node_address_prefix" {
default = ["10.11.1.0/24"]
}

variable "resource_prefix" {
type = string
default = null
}

variable "hostname" {
  type        = list(string)
  description = "The hostname of the machine"
  default = null
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed"
  type = string
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure"
  type = string
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  type = string
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."
  default = null
#  default = {
#    Environment = "Test"
#  }
}

variable "public_ip_address_allocation" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  default     = "Dynamic"
}

variable "node_count" {
type = number
default = null
}

variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics"
  default     = "Standard_LRS"
}