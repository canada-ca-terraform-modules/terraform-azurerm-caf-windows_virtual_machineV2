locals {
  resource_group_name = strcontains(var.windows_VM.resource_group, "/resourceGroups/") ? regex("[^\\/]+$", var.windows_VM.resource_group) :  var.resource_groups[var.windows_VM.resource_group].name
  subnet_id = strcontains(var.windows_VM.subnet, "/resourceGroups/") ? var.windows_VM.subnet : var.subnets[var.windows_VM.subnet].id
  vm-admin-password = try(data.azurerm_key_vault.key_vault[0].enable_rbac_authorization, false) && try(var.windows_VM.password_overwrite, false) ?  random_password.vm-admin-password[0].result : var.windows_VM.admin_password

}