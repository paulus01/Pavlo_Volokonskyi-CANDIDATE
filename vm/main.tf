# resource "azurerm_resource_group" "pavlo-candidate-rg" {
#   location = var.resource_group_location
#   name     = "Pavlo-Candidate"
# }

data "azurerm_resource_group" "pavlo-candidate-rg" {
  name = "Pavlo_Candidate"
}
# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "my-terraform-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.pavlo-candidate-rg.location
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "my-terraform-subnet"
  resource_group_name  = data.azurerm_resource_group.pavlo-candidate-rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "my-terraform-PublicIP"
  location            = data.azurerm_resource_group.pavlo-candidate-rg.location
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
  allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "my-terraform-NetworkSecurityGroup"
  location            = data.azurerm_resource_group.pavlo-candidate-rg.location
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name

  security_rule {
    name                       = "Jenkins-Server-SR"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "80", "8080"]
    source_address_prefixes    = ["217.138.217.62", "217.138.217.60", "212.103.49.110", "217.138.217.221", "185.236.200.58", "185.236.200.39", "212.103.49.81", "217.138.217.220"]
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "my-terraform-myNIC"
  location            = data.azurerm_resource_group.pavlo-candidate-rg.location
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name

  ip_configuration {
    name                          = "my-terraform-nic-configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "my-nsg-assoc" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

# Create (and display) an SSH key
resource "tls_private_key" "secureadmin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "Jenkins-Server"
  location              = data.azurerm_resource_group.pavlo-candidate-rg.location
  resource_group_name   = data.azurerm_resource_group.pavlo-candidate-rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "my-terraform-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  computer_name                   = "Jenkins-Server"
  admin_username                  = "ubuntu"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "ubuntu"
    public_key = tls_private_key.secureadmin_ssh.public_key_openssh
  }

  # custom_data = base64encode(file("${path.module}/custom-script.sh"))

}

resource "azurerm_virtual_machine_extension" "custom_script" {
  name                 = "custom_script"
  virtual_machine_id   = azurerm_linux_virtual_machine.my_terraform_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "script": "${filebase64("${path.module}/custom-script.sh")}"
    }
SETTINGS
}
