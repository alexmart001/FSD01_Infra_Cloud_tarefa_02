# Create a virtual network
resource "azurerm_virtual_network" "vnet_task_02" {
    name                = "vnet_task_02"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg_task_02.name

    tags = {
        environment = "Task 02"
    }
}

# Create subnet
resource "azurerm_subnet" "subnet_task_02" {
    name                 = "subnet_task_02"
    resource_group_name  = azurerm_resource_group.rg_task_02.name
    virtual_network_name = azurerm_virtual_network.vnet_task_02.name
    address_prefixes       = ["10.0.2.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip_task_02" {
    name                         = "publicip_task_02"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg_task_02.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Task 02"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg_task_02" {
    name                = "nsg_task_02"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg_task_02.name

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

    security_rule {
        name                       = "MySQLInbound"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Task 02"
    }
}

# Create network interface
resource "azurerm_network_interface" "nic_task_02" {
    name                        = "nic_task_02"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.rg_task_02.name

    ip_configuration {
        name                          = "nic_task_02"
        subnet_id                     = azurerm_subnet.subnet_task_02.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicip_task_02.id
    }

    tags = {
        environment = "Task 02"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsga_task_02" {
    network_interface_id      = azurerm_network_interface.nic_task_02.id
    network_security_group_id = azurerm_network_security_group.nsg_task_02.id
}

data "azurerm_public_ip" "ip_task_02_data" {
  name                = azurerm_public_ip.publicip_task_02.name
  resource_group_name = azurerm_resource_group.rg_task_02.name
}