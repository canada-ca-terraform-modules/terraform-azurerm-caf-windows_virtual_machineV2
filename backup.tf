locals {
  postfix                            = "-rsv"
  maxLenght                          = 50 #
  env_4                              = substr(var.env, 0, 4)
  regex                              = "/[^0-9A-Za-z-]/"
  userDefinedString_replaced         = replace(var.userDefinedString, "_", "-")
  userDefinedString_replaced_shorten = substr(local.userDefinedString_replaced, 0, local.maxLenght - length(local.postfix) - length(local.env_4) - 4)
  rsv-name                           = substr(replace("${local.env_4}CNR-${local.userDefinedString_replaced_shorten}${local.postfix}", local.regex, ""), 0, local.maxLenght)
  policy-name                        = "${var.env}CNR-${var.group}_${var.project}-${try(var.windows_VM.backup.policy-name, "daily1")}-rsvp"
}

data "azurerm_recovery_services_vault" "rsv" {
  name                = local.rsv-name
  resource_group_name = var.resource_groups["Backups"]
}

data "azurerm_backup_policy_vm" "backup_policy" {
  name                = local.policy-name
  recovery_vault_name = data.azurerm_recovery_services_vault.rsv.name
  resource_group_name = data.azurerm_recovery_services_vault.rsv.resource_group_name
}

resource "azurerm_backup_protected_vm" "backup_vm" {
  count               = try(var.windows_VM.disable_backup, false) == false ? 1 : 0
  resource_group_name = data.azurerm_recovery_services_vault.rsv.resource_group_name
  recovery_vault_name = data.azurerm_recovery_services_vault.rsv.name
  source_vm_id        = azurerm_windows_virtual_machine.wm.id
  backup_policy_id    = data.azurerm_backup_policy_vm.backup_policy.id

  exclude_disk_luns = try(var.windows_VM.backup.exclude_disk_luns, null)
  include_disk_luns = try(var.windows_VM.backup.include_disk_luns, null)
  protection_state  = try(var.windows_VM.backup.protection_state, null)
}
