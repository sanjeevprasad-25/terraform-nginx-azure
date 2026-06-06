output "Resource_Group_Name" {
    value = azurerm_resource_group.rg_web.name 
}
output "Resource_Virtual_Network" {
    value = azurerm_virtual_network.rg_web_network.name
}
output "Linux_VM_Name" {
    value = azurerm_linux_virtual_machine.web_vm.name
}
output "Sptechno_Public_IP" {
    value = azurerm_public_ip.rg_web_public_ip.ip_address
}