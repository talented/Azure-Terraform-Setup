variable "cluster_name" {
  description = "The name to give to this environment. Will be used for naming various resources."
  type        = string
}

variable "azurerm_resource_group" {
  description = "The name of the resource group to create the environment in."
  type        = string
}

variable "resource_group_location" {
  description = "The location to create the resource group in."
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block to use for the virtual network."
  type        = string
}

variable "subnet_1" {
  description = "The name of the first subnet."
  type        = string
}

variable "subnet_2" {
  description = "The name of the second subnet."
  type        = string
}

variable "account_tier" {
  description = "The tier of the storage account to create."
  type        = string
  default     = "Standard"
}

variable "storage_account_type" {
  description = "The type of storage account to create."
  type        = string
  default     = "Standard_LRS"
}

variable "account_replication_type" {
  description = "The replication type of the storage account to create."
  type        = string
  default     = "LRS"
}

variable "size_of_disk" {
  description = "The size of the disk to create."
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine to create."
  type        = string
  default     = "ubuntu-vm"
}

variable "vm_count" {
  description = "The number of virtual machines to create."
  type        = string
  default     = "1"
}

variable "computer_name" {
  description = "The name of the computer to use for the virtual machine."
  type        = string
  default     = "ubuntu-vm"
}

variable "admin_username" {
  description = "The username to use for the virtual machine."
  type        = string
  default     = "admin"
}

variable "image_publisher" {
  description = "The OS image to be used for the virtual machine."
  type        = string
}

variable "image_offer" {
  description = "The offer of the OS image to be used for the virtual machine."
  type        = string
}

variable "image_sku" {
  description = "The SKU of the OS image to be used for the virtual machine."
  type        = string
}

variable "image_version" {
  description = "The version of the OS image to be used for the virtual machine."
  type        = string
}

variable "disk_name" {
  description = "The name of the disk to create."
  type        = string
}
