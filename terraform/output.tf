output "resource_group_name" {
  value = azurerm_resource_group.ubuntu-rg.name
}

output "public_ip_address_list" {
  value = azurerm_linux_virtual_machine.ubuntu-vm.*.public_ip_address
}

output "network-nsg-id" {
  value = azurerm_network_security_group.ubuntu-sg.id
}

output "network-subnet-id" {
  value = azurerm_subnet.ubuntu-subnet1.id
}

output "admin_username" {
  value = var.admin_username
}
