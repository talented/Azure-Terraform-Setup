# Create a virtual network within the resource group
# az network vnet create -g resource_group_name -n name --address-prefix cidr_block
resource "azurerm_virtual_network" "ubuntu" {
  name                = "ubuntu-network"
  resource_group_name = var.azurerm_resource_group
  location            = var.resource_group_location
  address_space       = [var.cidr_block]

  # subnet {
  #   name           = "subnet1"
  #   address_prefix = var.subnet_1
  #   security_group = azurerm_network_security_group.ubuntu.id
  # }

  # subnet {
  #   name           = "subnet2"
  #   address_prefix = var.subnet_2
  #   security_group = azurerm_network_security_group.ubuntu.id
  # }

  # tags = {
  #   environment = "testing"
  # }
}

# Create subnets
# az network vnet subnet create -g $rg --vnet-name $vnet -n $subnet \
# --address-prefixes $subnetaddressprefix --network-security-group $nsg
resource "azurerm_subnet" "ubuntu1" {
  name                 = "subnet1"
  resource_group_name  = var.azurerm_resource_group
  virtual_network_name = azurerm_virtual_network.ubuntu.name
  address_prefixes     = [var.subnet_1]
}

# resource "azurerm_subnet" "ubuntu2" {
#   name                 = "subnet2"
#   resource_group_name  = var.azurerm_resource_group
#   virtual_network_name = azurerm_virtual_network.ubuntu.name
#   address_prefixes     = [var.subnet_2]
# }

# Create public IPs
# az network public-ip create -n $clientpip -g $rg
resource "azurerm_public_ip" "ubuntu" {
  count               = var.vm_count
  name                = "ubuntu-public-ip-0${count.index}"
  location            = var.resource_group_location
  resource_group_name = var.azurerm_resource_group
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
# az network nsg create -g $rg -n $nsg
resource "azurerm_network_security_group" "ubuntu" {
  name                = "ubuntu-security-group"
  location            = var.resource_group_location
  resource_group_name = var.azurerm_resource_group

  # az network nsg rule create -g $rg -n SSH --access allow \
  # --destination-address-prefixes '*' --destination-port-range 22 \
  # --direction inbound --nsg-name $nsg --protocol tcp --source-address-prefixes '*' \
  # --source-port-range '*' --priority 1000
  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # az network nsg rule create -g $rg -n k8s-api --access allow \
  # --destination-address-prefixes '*' --destination-port-range 22 \
  # --direction inbound --nsg-name $nsg --protocol tcp --source-address-prefixes '*' \
  # --source-port-range '*' --priority 1000
  security_rule {
    name                       = "k8s-api"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
# az network nic create -g $rg -n $clientnic --private-ip-address $clientvmprivateip \
# --public-ip-address $clientpip --vnet $vnet --subnet $subnet --ip-forwarding
resource "azurerm_network_interface" "ubuntu" {
  count               = var.vm_count
  name                = "ubuntu-ni-${count.index}"
  location            = var.resource_group_location
  resource_group_name = var.azurerm_resource_group

  ip_configuration {
    name = "ubuntu-ni-configuration"
    # subnet_id = azurerm_virtual_network.ubuntu.subnet.id
    subnet_id                     = azurerm_subnet.ubuntu1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.ubuntu.*.id, count.index)
    # public_ip_address_id          = azurerm_public_ip.ubuntu.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "ubuntu" {
  count                     = var.vm_count
  network_interface_id      = element(azurerm_network_interface.ubuntu.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.ubuntu.id
}
