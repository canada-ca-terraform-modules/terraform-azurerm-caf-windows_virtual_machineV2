locals {
  resource_group_name = strcontains(var.windows_VM.resource_group, "/resourceGroups/") ? regex("[^\\/]+$", var.windows_VM.resource_group) :  var.resource_groups[var.windows_VM.resource_group].name
  vm-admin-password = try(data.azurerm_key_vault.key_vault[0].enable_rbac_authorization, false) && !try(var.windows_VM.password_overwrite, false) ?  random_password.vm-admin-password[0].result : var.windows_VM.admin_password
  backup-policy-name = strcontains(try(var.windows_VM.backup_policy, "daily1"), "/resourceGroups/") ? regex("[^\\/]+$", var.windows_VM.backup_policy) : "${var.env}CNR-${var.group}_${var.project}-${try(var.windows_VM.backup_policy, "daily1")}-rsvp"

  nics = [for nic in azurerm_network_interface.vm-nic : nic.id]
  nic_indices = {for k, v in var.windows_VM.nic : k => index(keys(var.windows_VM.nic), k)}
}