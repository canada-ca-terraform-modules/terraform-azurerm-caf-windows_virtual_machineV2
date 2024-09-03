output "windows_vm_object" {
  description = "Outputs the entire VM object"
  value = azurerm_windows_virtual_machine.vm
}

output "windows_vm_id" {
  description = "Outputs the id of the VM"
  value = azurerm_windows_virtual_machine.vm.id
}

output "windows_vm_name" {
  description = "Outputs the name of the VM"
  value = azurerm_windows_virtual_machine.vm.name
}