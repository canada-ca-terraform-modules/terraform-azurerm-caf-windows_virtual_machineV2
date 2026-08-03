# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.0] - 2026-08-03

### Changed

- Upgraded `azurerm` provider requirement from `~> 4.0` to `~> 5.0` (tested against `5.0.1`, matching the target version requested for this upgrade).
- Bumped the `boot_diagnostic_storage` child module (`terraform-azurerm-caf-storage_accountV2`) from `v1.1.0` to `v1.2.0` to match its own azurerm `~> 5.0` requirement.
- Bumped GitHub Actions pins: `actions/checkout` v6.0.2 → v7.0.1, `hashicorp/setup-terraform` v4.0.0 → v4.0.1, `terraform-linters/setup-tflint` v6.2.2 → v6.3.0 (`terraform-docs/gh-actions` already current at v1.4.1).
- Bumped the `ESLZ/SRV-Windows.tf` module source ref from `v1.1.1` to `v1.2.0`.

### Notes

- No code changes were required in any resource block. Per the [azurerm 5.0 upgrade guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/5.0-upgrade-guide), the only breaking change affecting `azurerm_windows_virtual_machine` (removal of `enable_automatic_updates` in favour of `automatic_updates_enabled`) was already handled by this module's existing backward-compatible `automatic_updates_enabled`/`enable_automatic_updates` fallback in `module.tf` and `locals.tf`, added during the prior 4.x upgrade.
- All other resources and data sources used by this module (`azurerm_network_interface`, `azurerm_managed_disk`, `azurerm_virtual_machine_data_disk_attachment`, `azurerm_network_security_group`, the NIC association resources, `azurerm_backup_protected_vm`, `azurerm_dev_test_global_vm_shutdown_schedule`, `azurerm_key_vault`, `azurerm_recovery_services_vault`, `azurerm_backup_policy_vm`, `azurerm_subscription`) have zero breaking changes listed in the 5.0 upgrade guide.
- Existing tfvars (`ESLZ/SRV-Windows.tfvars`, `ESLZ/SRV-Windows-complete.tfvars`) require no changes — full backward compatibility preserved.
- All 9 existing `terraform test` runs (across `tests/windows_virtual_machine.tftest.hcl` and `tests/upgrade_compat.tftest.hcl`) pass unchanged against the `azurerm 5.0.1` provider. `terraform validate` and `tflint --recursive` are clean.
- Provider-level behavioural changes in 5.0 (`resource_provider_registrations` default changed from `legacy` to `none`; `enhanced_validation` disabled by default) are configured in the calling root module's `provider "azurerm"` block, not in this module — documented in the README's "Migration notes (azurerm 5.x)" section for caller awareness.

### Known blockers

- None. The user-requested target version `5.0.1` is a real published release and was installed and tested as-is.

## [1.1.0] - prior release

- Upgraded module to `azurerm ~> 4.0` and added compliance artifacts (`.gitignore`, `.tflint.hcl`, `providers.tf`, CI workflows, tests).
- Added optional name overrides for all auto-generated resource names (`vm_name`, `nsg_name`, `os_disk.name`, NIC `name`/`ip_configuration_name`, data disk `name`, `kv_secret_name`).
