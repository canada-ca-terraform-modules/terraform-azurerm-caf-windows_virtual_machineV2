# config/windows_virtual_machineV2.tfvars
# Minimal, valid fixture for the terraform-azurerm-caf-windows_virtual_machineV2
# live-test harness.
#
# This harness deploys into its own throwaway resource group + vnet/subnet
# (see test_dependencies.tf) - no shared resource group permissions needed,
# and no risk of colliding with any real resource.
#
# admin_password is a literal, obviously-fake placeholder - never a real
# secret. It must be a known-at-plan-time literal (not a generated value from
# another resource in this same harness): the module's secret.tf gates a
# random_password/data-source lookup on
# `try(var.windows_VM.admin_password, "") == "" ? 1 : 0`, and Terraform
# cannot resolve that count expression if admin_password is itself an
# unknown-until-apply value from a fresh resource in the same plan.
#
# vm_size is Standard_D2as_v6 (Dav6 family), not the Dsv5/Dasv5 family
# default seen elsewhere - the sandbox subscription's Dsv5/Dasv5 quota in
# canadacentral hits a hard Azure capacity restriction there; Dav6 quota was
# provisioned specifically to avoid this (see module-live-test-conversion
# skill preconditions).

windows_VMs = {
  livetest = {
    serverType     = "SWJ"
    resource_group = "Project" # resolved via test_dependencies.tf's resource_groups map
    admin_username = "azureadmin"
    admin_password = "CHANGE-ME-P@ssw0rd1234!" # placeholder only - throwaway live-test VM, destroyed after each run
    vm_size        = "Standard_D2as_v6"

    # Skip the RSV/backup_policy data source lookups entirely - the sandbox
    # subscription has no Recovery Services Vault. jump_server=true skips
    # the data source count; disable_backup=true skips the backup resource
    # itself.
    jump_server    = true
    disable_backup = true

    nic = {
      nic1 = {
        subnet                        = "livetest" # resolved via test_dependencies.tf's subnets map
        private_ip_address_allocation = "Dynamic"
      }
    }

    storage_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-g2"
      version   = "latest"
    }
  }
}
