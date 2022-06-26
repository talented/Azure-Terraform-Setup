output "resource_group_name" {
  value = azurerm_resource_group.ubuntu.name
}

output "public_ip_address_list" {
  value = azurerm_linux_virtual_machine.ubuntu.*.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.ubuntu_ssh.private_key_pem
  sensitive = true
}
