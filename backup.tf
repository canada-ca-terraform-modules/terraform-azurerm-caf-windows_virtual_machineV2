locals {
  postfix   = "-rsv"
  maxLenght = 50
  env_4_bk  = substr(var.env, 0, 4)
  regex     = "/[^0-9A-Za-z-]/"
  rsv-name  = substr(replace("${local.env_4_bk}CNR-${var.group}-${var.project}${local.postfix}", local.regex, ""), 0, local.maxLenght)
}

# Get the RSV from the target sub
data "azurerm_recovery_services_vault" "rsv" {
  count               = try(var.windows_VM.jump_server, false) == true ? 0 : 1
  name                = local.rsv-name
  resource_group_name = var.resource_groups["Backups"].name
}

# Get the desired backup policy from the RSV
data "azurerm_backup_policy_vm" "backup_policy" {
  count               = try(var.windows_VM.jump_server, false) == true ? 0 : 1
  name                = local.backup-policy-name
  recovery_vault_name = data.azurerm_recovery_services_vault.rsv[0].name
  resource_group_name = data.azurerm_recovery_services_vault.rsv[0].resource_group_name
}

resource "azurerm_backup_protected_vm" "backup_vm" {
  count               = try(var.windows_VM.disable_backup, false) == false ? 1 : 0
  resource_group_name = try(var.windows_VM.jump_server, false) == true ? var.resource_groups["Backups"].name : data.azurerm_recovery_services_vault.rsv[0].resource_group_name
  recovery_vault_name = try(var.windows_VM.jump_server, false) == true ? local.rsv-name : data.azurerm_recovery_services_vault.rsv[0].name
  source_vm_id        = azurerm_windows_virtual_machine.vm.id
  # When jump_server = true, backup_policy_id is taken directly from var.windows_VM.backup_policy —
  # the caller MUST supply a full ARM resource ID (e.g. /subscriptions/.../backupPolicies/daily1).
  # The non-jump_server path resolves the ID via the data source above.
  backup_policy_id = try(var.windows_VM.jump_server, false) == true ? var.windows_VM.backup_policy : data.azurerm_backup_policy_vm.backup_policy[0].id

  exclude_disk_luns = try(var.windows_VM.backup.exclude_disk_luns, null)
  include_disk_luns = try(var.windows_VM.backup.include_disk_luns, null)
  protection_state  = try(var.windows_VM.backup.protection_state, null)

  lifecycle {
    ignore_changes = [
      source_vm_id # Ignore casing differences returned by Azure API
    ]
    replace_triggered_by = [
      azurerm_windows_virtual_machine.vm.id # Recreate when VM is replaced
    ]
  }
}
