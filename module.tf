resource "azurerm_windows_virtual_machine" "vm" {
  name                  = local.vm-name
  location              = var.location
  resource_group_name   = local.resource_group_name
  size                  = var.windows_VM.vm_size
  admin_username        = var.windows_VM.admin_username
  admin_password        = local.vm-admin-password
  network_interface_ids = local.nics

  # Optional parameters
  allow_extension_operations                             = try(var.windows_VM.allow_extension_operations, true)
  availability_set_id                                    = try(var.windows_VM.availability_set_id, null)
  bypass_platform_safety_checks_on_user_schedule_enabled = try(var.windows_VM.bypass_platform_safety_checks_on_user_schedule_enabled, false)
  capacity_reservation_group_id                          = try(var.windows_VM.capacity_reservation_group_id, null)
  computer_name                                          = try(var.windows_VM.computer_name, local.vm-name)
  user_data                                              = var.user_data
  dedicated_host_id                                      = try(var.windows_VM.dedicated_host_id, null)
  dedicated_host_group_id                                = try(var.windows_VM.dedicated_host_group_id, null)
  edge_zone                                              = try(var.windows_VM.edge_zone, null)
  disk_controller_type                                   = try(var.windows_VM.disk_controller_type, null)
  enable_automatic_updates                               = try(var.windows_VM.enable_automatic_updates, true)
  encryption_at_host_enabled                             = try(var.windows_VM.encryption_at_host_enabled, null)
  eviction_policy                                        = try(var.windows_VM.eviction_policy, null)
  extensions_time_budget                                 = try(var.windows_VM.extensions_time_budget, "PT1H30M")
  hotpatching_enabled                                    = try(var.windows_VM.hotpatching_enabled, false)
  license_type                                           = try(var.windows_VM.license_type, null)
  max_bid_price                                          = try(var.windows_VM.max_bid_price, -1)
  patch_assessment_mode                                  = try(var.windows_VM.patch_assessment_mode, "AutomaticByPlatform")
  patch_mode                                             = try(var.windows_VM.patch_mode, "AutomaticByPlatform")
  platform_fault_domain                                  = try(var.windows_VM.platform_fault_domain, null)
  priority                                               = try(var.windows_VM.priority, "Regular")
  provision_vm_agent                                     = try(var.windows_VM.provision_vm_agent, true)
  proximity_placement_group_id                           = try(var.windows_VM.proximity_placement_group_id, null)
  reboot_setting                                         = try(var.windows_VM.reboot_setting, "Never")
  secure_boot_enabled                                    = try(var.windows_VM.secure_boot_enabled, false)
  source_image_id                                        = try(var.windows_VM.source_image_id, null)
  timezone                                               = try(var.windows_VM.timezone, "UTC-11")
  virtual_machine_scale_set_id                           = try(var.windows_VM.virtual_machine_scale_set_id, null)
  vm_agent_platform_updates_enabled                      = try(var.windows_VM.vm_agent_platform_updates_enabled, false)
  vtpm_enabled                                           = try(var.windows_VM.vtpm_enabled, null)
  zone                                                   = try(var.windows_VM.zone, null)

  os_disk {
    name                      = "${local.vm-name}-osdisk1"
    caching                   = try(var.windows_VM.os_disk.caching, "ReadWrite")
    storage_account_type      = try(var.windows_VM.os_disk.storage_account_type, "Standard_LRS")
    disk_size_gb              = try(var.windows_VM.os_disk.disk_size_gb, null)
    write_accelerator_enabled = try(var.windows_VM.write_accelerator_enabled, false)
  }

  dynamic "source_image_reference" {
    for_each = try(var.windows_VM.source_image_id, null) == null ? [1] : []
    content {
      publisher = var.windows_VM.storage_image_reference.publisher
      offer     = var.windows_VM.storage_image_reference.offer
      sku       = var.windows_VM.storage_image_reference.sku
      version   = var.windows_VM.storage_image_reference.version
    }
  }

  dynamic "additional_capabilities" {
    for_each = try(var.windows_VM.additional_capabilities, null) != null ? [1] : []
    content {
      ultra_ssd_enabled   = try(var.windows_VM.additional_capabilities.ultra_ssd_enabled, false)
      hibernation_enabled = try(var.windows_VM.additional_capabilities.hibernation_enabled, false)
    }
  }

  dynamic "additional_unattend_content" {
    for_each = try(var.windows_VM.additional_unattend_content, null) != null ? [1] : []
    content {
      content = each.value.additional_unattend_content.content
      setting = each.value.additional_unattend_content.setting
    }
  }

  dynamic "boot_diagnostics" {
    for_each = try(var.windows_VM.boot_diagnostic, false) != false ? [1] : []
    content {
      storage_account_uri = module.boot_diagnostic_storage[0].storage-account-object.primary_blob_endpoint
    }
  }

  # dynamic "diff_disk_settings" {
  #   for_each = try(var.windows_VM.diff_disk_settings, null) != null ? [1] : []
  #   content {
  #     option = var.windows_VM.diff_disk_settings.option
  #     placement = try(var.windows_VM.diff_disk_settings.placement, "CacheDisk")
  #   }
  # }

  dynamic "gallery_application" {
    for_each = try(var.windows_VM.gallery_application, null) != null ? [1] : []
    content {
      version_id                                  = each.value.gallery_application.version_id
      automatic_upgrade_enabled                   = try(each.value.gallery_application.automatic_upgrade_enabled, false)
      configuration_blob_uri                      = try(each.value.gallery_application.configuration_blob_uri, null)
      order                                       = try(each.value.gallery_application.order, 0)
      tag                                         = try(each.value.gallery_application.tag, null)
      treat_failure_as_deployment_failure_enabled = try(each.value.gallery_application.treat_failure_as_deployment_failure_enabled, false)
    }
  }

  dynamic "identity" {
    for_each = try(var.windows_VM.identity, null) != null || try(var.windows_VM.boot_diagnostic, false) == true ? [1] : []
    content {
      type         = try(var.windows_VM.identity.type, "SystemAssigned")
      identity_ids = try(var.windows_VM.identity.identity_ids, [])
    }
  }

  dynamic "secret" {
    for_each = try(var.windows_VM.secret, null) != null ? [1] : []
    content {
      dynamic "certificate" {
        for_each = var.windows_VM.secret.certificate
        content {
          store = each.value.certificate.store
          url   = each.value.certificate.url
        }
      }
      key_vault_id = var.windows_VM.certificate.key_vault_id
    }
  }

  dynamic "plan" {
    for_each = try(var.windows_VM.plan, null) != null ? [1] : []
    content {
      name      = var.windows_VM.plan.name
      product   = var.windows_VM.plan.product
      publisher = var.windows_VM.plan.publisher
    }
  }

  dynamic "os_image_notification" {
    for_each = try(var.windows_VM.os_image_notification, null) != null ? [1] : []
    content {
      timeout = try(var.windows_VM.os_image_notification, "PT15M")
    }
  }

  dynamic "termination_notification" {
    for_each = try(var.windows_VM.termination_notification, null) != null ? [1] : []
    content {
      enabled = var.windows_VM.termination_notification.enabled
      timeout = try(var.windows_VM.termination_notification.timeout, "PT5M")
    }
  }

  dynamic "winrm_listener" {
    for_each = try(var.windows_VM.winrm_listener, null) != null ? [1] : []
    content {
      protocol        = each.value.winrm_listener.protocol
      certificate_url = try(each.value.winrm_listener.certificate_url, null)
    }
  }

  tags = merge(var.tags, try(var.windows_VM.tags, {}), [try(var.windows_VM.computer_name, null) != null ? { "OsHostname" = var.windows_VM.computer_name } : null]...)

  lifecycle {
    ignore_changes = [admin_username, admin_password, identity, os_disk, tags]
  }
}

resource "azurerm_network_interface" "vm-nic" {
  for_each            = var.windows_VM.nic
  name                = "${local.vm-name}-nic${local.nic_indices[each.key] + 1}"
  location            = var.location
  resource_group_name = local.resource_group_name

  dns_servers                    = try(each.value.dns_servers, null)
  edge_zone                      = try(each.value.edge_zone, null)
  ip_forwarding_enabled          = try(each.value.ip_forwarding_enabled, false)
  accelerated_networking_enabled = try(each.value.accelerated_networking_enabled, false)
  internal_dns_name_label        = try(each.value.internal_dns_name_label, null)

  tags = merge(var.tags, try(each.value.tags, {}))

  ip_configuration {
    name                          = "${local.vm-name}-ipconfig${local.nic_indices[each.key] + 1}"
    private_ip_address_allocation = try(each.value.private_ip_address_allocation, "Dynamic")
    private_ip_address            = try(each.value.private_ip_address_allocation, "Dynamic") == "Dynamic" ? null : each.value.private_ip_address
    subnet_id                     = strcontains(each.value.subnet, "/resourceGroups/") ? each.value.subnet : var.subnets[each.value.subnet].id
    private_ip_address_version    = try(each.value.nic.private_ip_address_version, "IPv4")
    primary                       = local.nic_indices[each.key] == 0 ? true : false

  }
}

resource "azurerm_managed_disk" "data_disks" {
  for_each = try(var.windows_VM.data_disks, {})

  name                 = "${local.vm-name}-datadisk${each.value.lun + 1}"
  resource_group_name  = local.resource_group_name
  location             = var.location
  storage_account_type = try(each.value.os_managed_disk_type, "StandardSSD_LRS")
  create_option        = try(each.value.disk_create_option, "Empty")
  disk_size_gb         = try(each.value.disk_size_gb, 256)

  #Optional paramaters
  disk_iops_read_write              = try(each.value.disk_iops_read_write, null)
  disk_mbps_read_write              = try(each.value.disk_mbps_read_write, null)
  disk_iops_read_only               = try(each.value.disk_iops_read_only, null)
  disk_mbps_read_only               = try(each.value.disk_mbps_read_only, null)
  upload_size_bytes                 = try(each.value.upload_size_bytes, null)
  edge_zone                         = try(each.value.edge_zone, null)
  hyper_v_generation                = try(each.value.hyper_v_generation, null)
  image_reference_id                = try(each.value.image_reference_id, null)
  gallery_image_reference_id        = try(each.value.gallery_image_reference_id, null)
  logical_sector_size               = try(each.value.logical_sector_size, null)
  optimized_frequent_attach_enabled = try(each.value.optimized_frequent_attach_enabled, false)
  performance_plus_enabled          = try(each.value.performance_plus_enabled, false)
  os_type                           = try(each.value.os_type, null)
  source_resource_id                = try(each.value.source_resource_id, null)
  source_uri                        = try(each.value.source_uri, null)
  storage_account_id                = try(each.value.storage_account_id, null)
  tier                              = try(each.value.tier, null)
  max_shares                        = try(each.value.max_shares, null)
  trusted_launch_enabled            = try(each.value.trusted_launch_enabled, null)
  security_type                     = try(each.value.security_type, null)
  secure_vm_disk_encryption_set_id  = try(each.value.secure_vm_disk_encryption_set_id, null)
  on_demand_bursting_enabled        = try(each.value.on_demand_bursting_enabled, null)
  zone                              = try(each.value.zone, null)
  public_network_access_enabled     = try(each.value.public_network_access_enabled, false)


  tags = merge(var.tags, try(each.value.tags, {}))

  lifecycle {
    ignore_changes = [name, create_option, source_resource_id, tags, zone, ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disks_attachment" {
  for_each = try(var.windows_VM.data_disks, {})

  virtual_machine_id        = azurerm_windows_virtual_machine.vm.id
  managed_disk_id           = azurerm_managed_disk.data_disks[each.key].id
  lun                       = each.value.lun
  caching                   = try(each.value.caching, "ReadWrite")
  create_option             = try(each.value.create_option, "Attach")
  write_accelerator_enabled = try(each.value.write_accelerator_enabled, false)

  lifecycle {
    ignore_changes = [managed_disk_id, virtual_machine_id]
  }
}

resource "azurerm_network_security_group" "NSG" {
  count               = try(var.windows_VM.use_nic_nsg, false) ? 1 : 0
  name                = "${local.vm-name}-nsg"
  location            = var.location
  resource_group_name = local.resource_group_name

  dynamic "security_rule" {
    for_each = [for sr in var.windows_VM.security_rules : {
      name                       = sr.name
      priority                   = sr.priority
      direction                  = sr.direction
      access                     = sr.access
      protocol                   = sr.protocol
      source_port_ranges         = split(",", replace(sr.source_port_ranges[0], "*", "0-65535"))
      destination_port_ranges    = split(",", replace(sr.destination_port_ranges[0], "*", "0-65535"))
      source_address_prefixes      = sr.source_address_prefixes
      destination_address_prefixes = sr.destination_address_prefixes
      description                = sr.description
    }]
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_ranges         = security_rule.value.source_port_ranges
      destination_port_ranges    = security_rule.value.destination_port_ranges
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefixes = security_rule.value.destination_address_prefixes
      description                = security_rule.value.description
    }
  }

  tags = merge(var.tags, try(var.windows_VM.tags, {}))
}
