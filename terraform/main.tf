terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# create resource group
# az group create -n name -l westeurope
# terraform import azurerm_resource_group.ubuntu-rg \
# "/subscriptions/0732832d-0c9d-4164-bcfb-296f501a6a3e/resourceGroups/cloud-shell-storage-westeurope"
resource "azurerm_resource_group" "ubuntu-rg" {
  name     = var.azurerm_resource_group
  location = var.resource_group_location

  tags = {
    environment = var.environment
  }
}

# Create an SSH key
resource "tls_private_key" "ubuntu_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ubuntu_ssh_key" {
  filename = "ubuntu_ssh_key.pem"
  content  = tls_private_key.ubuntu_ssh.private_key_pem
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.ubuntu-rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
# az storage account create -n ubuntu -g resource_group_name --sku Standard_LRS
resource "azurerm_storage_account" "ubuntu-sa" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = azurerm_resource_group.ubuntu-rg.location
  resource_group_name      = azurerm_resource_group.ubuntu-rg.name
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}

# Create virtual machine
# az vm create -g $rg -n worker-1 --image ubuntults --availability-set  worker-avblset \
# --nics worker-1-nic --size $size --authentication-type password --admin-username $adminuser \
# --admin-password $adminpwd --use-unmanaged-disk --storage-sku Standard_LRS --os-disk-size-gb 200 
resource "azurerm_linux_virtual_machine" "ubuntu-vm" {
  count                 = var.vm_count
  name                  = "ubuntu-vm-${count.index}"
  location              = azurerm_resource_group.ubuntu-rg.location
  resource_group_name   = azurerm_resource_group.ubuntu-rg.name
  network_interface_ids = [element(azurerm_network_interface.ubuntu-ni.*.id, count.index)]
  #   network_interface_ids = [azurerm_network_interface.ubuntu-ni.id]
  size = var.size_of_disk

  os_disk {
    name                 = "${var.disk_name}-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  computer_name                   = count.index == 0 ? var.master_node : "${var.worker_node}-${count.index}"
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ubuntu_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.ubuntu-sa.primary_blob_endpoint
  }

  depends_on = [
    tls_private_key.ubuntu_ssh
  ]

  # custom_data = filebase64("test.sh")

  # Copy in the bash script we want to execute.
  # The source is the location of the bash script
  # on the local linux box you are executing terraform
  # from.  The destination is on the new Azure instance.
  #   provisioner "file" {
  #     source      = "test.sh"
  #     destination = "/tmp"
  #   }
  #   # Change permissions on bash script and execute from ec2-user.
  #     provisioner "remote-exec" {
  #       inline = [
  #         "chmod +x /tmp/test.sh",
  #         "sudo sh /tmp/test.sh",
  #       ]
  #   #   }
}
