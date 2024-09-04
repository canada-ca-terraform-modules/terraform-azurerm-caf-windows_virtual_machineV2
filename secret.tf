locals {
  group_4 = substr(var.group, 0, 4)
  project_3 = substr(var.project, 0, 3)
  kv_sha = substr(sha1(var.resource_groups["Keyvault"].id), 0, 4)
  kv_name = "${var.env}CKV-${local.group_4}-${local.project_3}-${local.kv_sha}-kv"
}

# Need to get info about the subscription key vault. If password_overwrite is true, then don't bother since we  won't use it
data "azurerm_key_vault" "key_vault" {
  count = try(var.windows_VM.password_overwrite, false) ? 0 : 1
  name = local.kv_name
  resource_group_name = var.resource_groups["Keyvault"].name
}

# Generate a password if it will be necessary. Since it it only an inital password, ignore all changes to it
resource "random_password" "vm-admin-password" {
  count            = try(data.azurerm_key_vault.key_vault[0].enable_rbac_authorization, false) && !try(var.windows_VM.password_overwrite, false) ? 1 : 0
  length           = 16
  special          = true
  override_special = "!#$%&*"
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1

  lifecycle {
    ignore_changes = all
  }
}

# Creates a secret in the subscription keyvault if a generated password is necessary. Since it will be only an inital password, ignore all changes to it
resource "azurerm_key_vault_secret" "vm-admin-password" {
  count        = try(data.azurerm_key_vault.key_vault[0].enable_rbac_authorization, false) && !try(var.windows_VM.password_overwrite, false) ? 1 : 0
  name         = "${local.vm-name}-vm-admin-password"
  value        = random_password.vm-admin-password[0].result
  key_vault_id = data.azurerm_key_vault.key_vault[0].id
  content_type = "password"

  lifecycle {
    ignore_changes = all
  }
}