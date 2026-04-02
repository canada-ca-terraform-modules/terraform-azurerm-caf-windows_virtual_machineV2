mock_provider "azurerm" {}
mock_provider "http" {}
mock_provider "null" {}
mock_provider "random" {}

variables {
  resource_groups = {
    Project  = { name = "rg-project", id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project" }
    Keyvault = { name = "rg-keyvault", id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-keyvault" }
    Backups  = { name = "rg-backups", id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-backups" }
  }
  subnets = {
    OZ = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/OZ" }
  }
  env               = "Dev1"
  group             = "SPC"
  project           = "TST"
  userDefinedString = "test"
  tags              = {}
}

# Step 1: plan baseline inputs (pre-upgrade config — no new args)
run "baseline_apply" {
  command = plan
  variables {
    windows_VM = {
      serverType     = "SWJ"
      resource_group = "Project"
      admin_username = "azureadmin"
      admin_password = "TestP@ss123!"
      vm_size        = "Standard_D2s_v5"
      jump_server    = true
      disable_backup = true
      nic = {
        nic1 = {
          subnet                        = "OZ"
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
  assert {
    condition     = azurerm_windows_virtual_machine.vm.name == "Dev1SWJ-test"
    error_message = "Baseline apply: unexpected VM name"
  }
}

# Step 2: plan with same inputs against deployed state — must not cause replacement
run "upgrade_plan_no_replacement" {
  command = plan
  variables {
    windows_VM = {
      serverType               = "SWJ"
      resource_group           = "Project"
      admin_username           = "azureadmin"
      admin_password           = "TestP@ss123!"
      vm_size                  = "Standard_D2s_v5"
      jump_server              = true
      disable_backup           = true
      enable_automatic_updates = true
      nic = {
        nic1 = {
          subnet                        = "OZ"
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
  assert {
    condition     = azurerm_windows_virtual_machine.vm.name == "Dev1SWJ-test"
    error_message = "Upgrade plan: resource name must not change (would force replacement)"
  }
}
