resource "azurerm_resource_group" "rg_web" {
    location= var.rg_location
    name= var.rg_name
    tags = {
      environment= var.rg_env
    }
}
resource "azurerm_virtual_network" "rg_web_network" {
    name= var.web_net
    location = azurerm_resource_group.rg_web.location
    resource_group_name = azurerm_resource_group.rg_web.name
    address_space = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "rg_web_sn" {
    name= var.web_sn
    resource_group_name = azurerm_resource_group.rg_web.name
    virtual_network_name = azurerm_virtual_network.rg_web_network.name
    address_prefixes = ["10.0.0.0/24"]
}
resource "azurerm_public_ip" "rg_web_public_ip" {
    name= "sptechno_public_ip"
    resource_group_name = azurerm_resource_group.rg_web.name
    location = azurerm_resource_group.rg_web.location
    allocation_method= "Static"
    tags= {
        environment= var.rg_env
    }  
}
resource "azurerm_network_security_group" "web_nsg" {
    name = "sptechno_web_nsg"
    location = azurerm_resource_group.rg_web.location
    resource_group_name = azurerm_resource_group.rg_web.name
    dynamic "security_rule" {
     for_each = local.sptechno_web_nsg
     content {
        name = security_rule.key
        destination_port_range = security_rule.value.destination_port
        priority = security_rule.value.priority
        description = security_rule.value.description
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        source_address_prefix = "*"
        destination_address_prefix = "*"
             }
        }
    } 
resource "azurerm_network_interface" "web_lan_card" {
    name = "sptechno_web_nic1"
    location = azurerm_resource_group.rg_web.location
    resource_group_name = azurerm_resource_group.rg_web.name
    ip_configuration {
        name = "web-nic-ip"
        subnet_id = azurerm_subnet.rg_web_sn.id
        private_ip_address_allocation = "Static"
        private_ip_address = "10.0.0.4"
        public_ip_address_id = azurerm_public_ip.rg_web_public_ip.id
     }
    }
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.web_lan_card.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}
resource "azurerm_linux_virtual_machine" "web_vm" {
    name = "linux-vm"
    computer_name = "linux-vm"
    resource_group_name = azurerm_resource_group.rg_web.name
    location = azurerm_resource_group.rg_web.location
    size = "Standard_B1s"
    admin_username = "azureuser"
    admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/azure_vm_key.pub")
            }
    disable_password_authentication = true
    network_interface_ids = [azurerm_network_interface.web_lan_card.id]
    os_disk {
            name = "linux_vm_os_disk"    
            caching = "ReadWrite"
            storage_account_type = "Standard_LRS"
            disk_size_gb = 30
            }
    source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
    }
}    

