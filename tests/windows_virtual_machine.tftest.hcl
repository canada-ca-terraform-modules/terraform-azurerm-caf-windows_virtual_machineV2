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

run "ip_configuration_name_override" {
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
          ip_configuration_name         = "custom-ipconfig-name"
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
    condition     = azurerm_network_interface.vm-nic["nic1"].ip_configuration[0].name == "custom-ipconfig-name"
    error_message = "NIC IP configuration name must use ip_configuration_name when provided"
  }
}

run "custom_resource_names" {
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
      vm_name        = "my-custom-vm"
      nsg_name       = "my-custom-nsg"
      use_nic_nsg    = true
      security_rules = []
      os_disk = {
        name = "my-custom-osdisk"
      }
      nic = {
        nic1 = {
          subnet                        = "OZ"
          private_ip_address_allocation = "Dynamic"
          name                          = "my-custom-nic"
          ip_configuration_name         = "my-custom-ipconfig"
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
    condition     = azurerm_windows_virtual_machine.vm.name == "my-custom-vm"
    error_message = "vm_name override must be used as the VM resource name"
  }
  assert {
    condition     = azurerm_windows_virtual_machine.vm.os_disk[0].name == "my-custom-osdisk"
    error_message = "os_disk.name override must be used as the OS disk name"
  }
  assert {
    condition     = azurerm_network_interface.vm-nic["nic1"].name == "my-custom-nic"
    error_message = "nic.name override must be used as the NIC resource name"
  }
  assert {
    condition     = azurerm_network_interface.vm-nic["nic1"].ip_configuration[0].name == "my-custom-ipconfig"
    error_message = "ip_configuration_name override must be used as the NIC IP config name"
  }
  assert {
    condition     = azurerm_network_security_group.NSG[0].name == "my-custom-nsg"
    error_message = "nsg_name override must be used as the NSG resource name"
  }
}

run "custom_data_url" {
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
    custom_data = "https://example.com/publicresources/my-custom-data.ps1"
  }
  assert {
    condition     = length(data.http.custom_data) == 1
    error_message = "An arbitrary http(s) URL passed as custom_data must be fetched via the http data source"
  }
  assert {
    condition     = data.http.custom_data[0].url == "https://example.com/publicresources/my-custom-data.ps1"
    error_message = "The http data source must fetch the URL provided in custom_data"
  }
}

run "custom_data_install_ca_certs_legacy_alias" {
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
    custom_data = "install-ca-certs"
  }
  assert {
    condition     = length(data.http.custom_data) == 1
    error_message = "The legacy install-ca-certs alias must still be fetched via the http data source"
  }
  assert {
    condition     = data.http.custom_data[0].url == "https://gcpcenteslzpublicblob4df.blob.core.windows.net/publicresources/windows-all-customdata-default.ps1"
    error_message = "install-ca-certs must resolve to the default customdata script URL"
  }
}

run "custom_data_plain_value_not_fetched" {
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
    custom_data = base64encode("Write-Output 'hello world'")
  }
  assert {
    condition     = length(data.http.custom_data) == 0
    error_message = "A plain custom_data value must be passed through without being fetched"
  }
  assert {
    condition     = azurerm_windows_virtual_machine.vm.custom_data == base64encode("Write-Output 'hello world'")
    error_message = "A plain custom_data value must be passed through as-is"
  }
}
