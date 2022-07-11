# Create a virtual network within the resource group
# az network vnet create -g resource_group_name -n name --address-prefix cidr_block
resource "azurerm_virtual_network" "ubuntu-vnet" {
  name                = "ubuntu-vnet"
  resource_group_name = azurerm_resource_group.ubuntu-rg.name
  location            = azurerm_resource_group.ubuntu-rg.location
  address_space       = [var.cidr_block]

  tags = {
    environment = var.environment
  }
}

# Create subnets
# az network vnet subnet create -g $rg --vnet-name $vnet -n $subnet \
# --address-prefixes $subnetaddressprefix --network-security-group $nsg
resource "azurerm_subnet" "ubuntu-subnet1" {
  name                 = "ubuntu-subnet1"
  resource_group_name  = azurerm_resource_group.ubuntu-rg.name
  virtual_network_name = azurerm_virtual_network.ubuntu-vnet.name
  address_prefixes     = [var.subnet_1]
}

# Optional
# resource "azurerm_subnet" "ubuntu-subnet2" {
#   name                 = "ubuntu-subnet2"
#   resource_group_name  = azurerm_resource_group.ubuntu-rg.name
#   virtual_network_name = azurerm_virtual_network.ubuntu-vnet.name
#   address_prefixes     = [var.subnet_2]
# }

# Create public IPs
# az network public-ip create -n $clientpip -g $rg
resource "azurerm_public_ip" "ubuntu-pip" {
  count               = var.vm_count
  name                = "ubuntu-public-ip-0${count.index}"
  location            = azurerm_resource_group.ubuntu-rg.location
  resource_group_name = azurerm_resource_group.ubuntu-rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
# az network nsg create -g $rg -n $nsg
resource "azurerm_network_security_group" "ubuntu-sg" {
  name                = "ubuntu-security-group"
  location            = azurerm_resource_group.ubuntu-rg.location
  resource_group_name = azurerm_resource_group.ubuntu-rg.name

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

# Create network interface - component which holds the Public IP and the private IP of the VM.
# NIC connects VM to the VNet
# az network nic create -g $rg -n $clientnic --private-ip-address $clientvmprivateip \
# --public-ip-address $clientpip --vnet $vnet --subnet $subnet --ip-forwarding
resource "azurerm_network_interface" "ubuntu-ni" {
  count               = var.vm_count
  name                = "ubuntu-ni-${count.index}"
  location            = azurerm_resource_group.ubuntu-rg.location
  resource_group_name = azurerm_resource_group.ubuntu-rg.name

  ip_configuration {
    name = "ubuntu-ni-configuration"
    # subnet_id = azurerm_virtual_network.ubuntu.subnet.id
    subnet_id                     = azurerm_subnet.ubuntu-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.ubuntu-pip.*.id, count.index)
    # public_ip_address_id          = azurerm_public_ip.ubuntu-pip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "ubuntu-ni-sga" {
  count                     = var.vm_count
  network_interface_id      = element(azurerm_network_interface.ubuntu-ni.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.ubuntu-sg.id
}
