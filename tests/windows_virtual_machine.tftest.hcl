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

run "naming_convention" {
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
    error_message = "Name must follow {env4}{serverType3}-{userDefinedString7} convention"
  }
}

run "default_values" {
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
    condition     = azurerm_windows_virtual_machine.vm.license_type == "Windows_Server"
    error_message = "Default license_type must be Windows_Server"
  }
  assert {
    condition     = azurerm_windows_virtual_machine.vm.patch_assessment_mode == "AutomaticByPlatform"
    error_message = "Default patch_assessment_mode must be AutomaticByPlatform"
  }
  assert {
    condition     = azurerm_windows_virtual_machine.vm.bypass_platform_safety_checks_on_user_schedule_enabled == true
    error_message = "Default bypass_platform_safety_checks must be true"
  }
}

run "automatic_updates_backward_compat" {
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
      enable_automatic_updates = false
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
    condition     = azurerm_windows_virtual_machine.vm.automatic_updates_enabled == false
    error_message = "Legacy enable_automatic_updates=false must map to automatic_updates_enabled=false"
  }
}

run "static_nic_ip" {
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
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.0.0.10"
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
    condition     = azurerm_network_interface.vm-nic["nic1"].ip_configuration[0].private_ip_address_allocation == "Static"
    error_message = "NIC must use Static IP allocation when configured"
  }
}

run "gallery_application_list" {
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
      gallery_application = [
        {
          version_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Compute/galleries/gal/applications/app1/versions/1.0.0"
        },
        {
          version_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Compute/galleries/gal/applications/app2/versions/2.0.0"
          order      = 1
        }
      ]
    }
  }
  assert {
    condition     = azurerm_windows_virtual_machine.vm.name == "Dev1SWJ-test"
    error_message = "VM name must be correct when gallery_application list is provided"
  }
}
