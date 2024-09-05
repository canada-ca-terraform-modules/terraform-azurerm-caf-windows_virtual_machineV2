module "boot_diagnostic_storage" {
  # source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-storage_accountV2.git?ref=v1.0.2"
  source = "/home/max/devops/modules/terraform-azurerm-caf-storage_accountV2"
  count = try(var.windows_VM.boot_diagnostic, false) ? 1 : 0
  userDefinedString    = "${var.userDefinedString}-logs"
  location             = var.location
  env                  = var.env
  resource_groups      = var.resource_groups
  subnets              = var.subnets
  private_dns_zone_ids = null
  tags                 = var.tags
  storage_account = {
    resource_group            = var.windows_VM.resource_group
    account_tier              = "Standard"
    account_replication_type  = "LRS"
    private_endpoint = {
      "${var.userDefinedString}-logs" = {
        resource_group = var.windows_VM.resource_group
        subnet = var.windows_VM.nic[keys(local.nic_indices)[0]].subnet
        subresource_names = ["blob"]
      }
    }
  }
}

resource "azurerm_role_assignment" "vm_contributor" {
  count = try(var.windows_VM.boot_diagnostic, false) ? 1 : 0
  scope = module.boot_diagnostic_storage[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = azurerm_windows_virtual_machine.vm.identity[0].principal_id
}