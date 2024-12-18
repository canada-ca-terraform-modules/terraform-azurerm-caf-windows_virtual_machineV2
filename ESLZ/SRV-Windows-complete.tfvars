# This file is an exhaustive list of all paramaters the module accepts. For a more compact version more readable in projects, use the other tfvars.
windows_VMs = {
  test = {
    serverType     = "SWJ"
    resource_group = "Project"
    admin_username = "azureadmin"
    # admin_password          = "Canada123!"                          # Optional: Only set the password if a generated password cannot be created. See README for details
    vm_size = "Standard_D2s_v5"

    backup_policy = "daily1" # Optional: Set this value to configure backup policy on the VM. Can be either userDefinedString portion of the policy name or ID. Defaults to daily1 
    # disable_backup           = false                                                                             # Optional: Set this value to true if you want to disable backups on this VM    
    enable_automatic_updates = true                  # (Optional) Specifies if Automatic Updates are Enabled for the Windows Virtual Machine. Changing this forces a new resource to be created.
    patch_assessment_mode    = "AutomaticByPlatform" # force settings to AutomaticByPlatform for UMC OS patching 
    patch_mode               = "AutomaticByPlatform" # force settings to AutomaticByPlatform for UMC OS patching 

    custom_data                                              = "install-ca-certs"
    # computer_name                                          = "Example"                                           # Optional: Set this if you need the guest OS Hostname to be different than the Azure resource name
    # user_data                                              = "post_install_scripts/ubuntu/post_install.sh"       # Optional: Set this value with the relative path to the file from your CWD.
    # boot_diagnostic                                        = true
    # use_nic_nsg                                            = true
    # allow_extension_operations                             = true
    # availability_set_id                                    = ""
    # bypass_platform_safety_checks_on_user_schedule_enabled = false
    # capacity_reservation_group_id                          = ""
    # dedicated_host_id                                      = ""
    # dedicated_host_group_id                                = ""
    # edge_zone                                              = ""
    # disk_controller_type                                   = ""
    # encryption_at_host_enabled                             = ""
    # eviction_policy                                        = ""
    # extensions_time_budget                                 = "PT1H30M"
    # hotpatching_enabled                                    = false
    # license_type                                           = ""
    # max_bid_price                                          = -1
    # platform_fault_domain                                  = ""
    # priority                                               = "Regular"
    # provision_vm_agent                                     = true
    # proximity_placement_group_id                           = ""
    # reboot_setting                                         = "Never"
    # secure_boot_enabled                                    = false
    # source_image_id                                        = ""
    # timezone                                               = "UTC-11"
    # virtual_machine_scale_set_id                           = ""
    # vm_agent_platform_updates_enabled                      = false
    # vtpm_enabled                                           = ""
    # zone                                                   = ""

    # At least one nic is required. If more than one is present, the first nic in the list will be the primary one.
    nic = {
      nic1 = {
        subnet                        = "APP"
        private_ip_address_allocation = "Static"
        private_ip_address            = "172.17.65.8"

        # dns_servers                    = []
        # edge_zone                      = ""
        # ip_forwarding_enabled          = false
        # accelerated_networking_enabled = false
        # internal_dns_name_label        = ""
      }
    }

    storage_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-g2"
      version   = "latest"
    }

    # Optional: Uncomment if you need to configure os_disk with different defaults than below. Only supports one os_disk
    # os_disk = {
    #   caching                   = "ReadWrite"
    #   storage_account_type      = "Standard_LRS"
    #   disk_size_gb              = 128
    #   write_accelerator_enabled = false
    # }

    # Optional: Uncomment and configure data disks for the VM. Can create more than one data disks.
    # data_disks = {
    #   disk1 = {
    #     storage_account_type = "StandardSSD_LRS"
    #     disk_create_option   = "Empty"
    #     disk_size_gb         = 500
    #     lun                  = 0
    #     caching              = "ReadWrite"
    #     # disk_iops_read_write                 = null
    #     # disk_mbps_read_write                 = null
    #     # disk_iops_read_only                  = null
    #     # disk_mbps_read_only                  = null
    #     # upload_size_bytes                    = null
    #     # edge_zone                            = null
    #     # hyper_v_generation                   = null
    #     # image_reference_id                   = null
    #     # gallery_image_reference_id           = null
    #     # logical_sector_size                  = null
    #     # optimized_frequent_attach_enabled    = false
    #     # performance_plus_enabled             = false
    #     # os_type                              = "Windows"
    #     # source_resource_id                   = null
    #     # source_uri                           = null
    #     # storage_account_id                   = null
    #     # tier                                 = null
    #     # max_shares                           = null
    #     # trusted_launch_enabled               = null
    #     # security_type                        = null
    #     # secure_vm_disk_encryption_set_id     = null
    #     # on_demand_bursting_enabled           = null
    #     # zone                                 = null
    #     # public_network_access_enabled        = false
    #   }
    # }

    # Optional: Uncomment this block to setup auto-shutdown on the VM.
    # auto_shutdown_config = {
    #   enabled               = true
    #   timezone              = "Eastern Standard Time"
    #   daily_recurrence_time = "1600"

    #   notification_settings = {
    #     enabled         = true
    #     email           = "maxime.mahdavian@ssc-spc.gc.ca"
    #     time_in_minutes = 30
    #   }
    # }

    # Optional: Uncomment this if you want to set an identityfor the VM. Note that if boot_diagnostic is Enabled then a SystemAssigned identity is automatically granted to the VM. 
    # identity = {
    #   type         = "SystemAssigned"
    #   identity_ids = []
    # }


    # Optional: Uncomment to configure boot diagnostic. DEfaults to using a managed storage account. 
    # boot_diagnostic = {
    #   use_managed_storage_account = true
    #   # storage_account_resource_id = ""        # Only valid if use_managed_storage_account = false
    # }

    # Optional: Uncomment this block to set a key vault where the TF generated password will be. Default is KV in the project subscription.
    # key_vault = {
    #   name = ""
    #   resource_group_name = "Keyvault"
    # }


    # Optional: Uncomment this if you want to set additional capabilities other than the default below
    # additional_capabilities = {
    #   ultra_ssd_enabled   = false
    #   hibernation_enabled = false
    # }

    # Optional: Uncomment this if you want to set additional_unattend_content
    # additional_unattend_content = {
    #   content = ""
    #   setting = ""
    # }

    # Optional: Uncomment this if you want to set gallery_application
    # gallery_application = {
    #   version_id                                  = ""
    #   automatic_upgrade_enabled                   = false
    #   configuration_blob_uri                      = ""
    #   order                                       = 0
    #   tag                                         = ""
    #   treat_failure_as_deployment_failure_enabled = false
    # }

    # secret = {
    #   certificate = {
    #     store = ""
    #     url   = ""
    #   }
    #   key_vault_id = ""
    # }

    # plan = {
    #   name      = ""
    #   product   = ""
    #   publisher = ""
    # }

    # os_image_notification = {
    #   timeout = "PT15M"
    # }

    # termination_notification = {
    #   enabled = false
    #   timeout = "PT5M"
    # }

    # winrm_listener = {
    #   protocol        = ""
    #   certificate_url = ""
    # }

    # load_balancer_address_pools_ids = {
    #   "ID" = {}
    # }

    # asg = {
    #   application_security_group_id = ""
    # }

    # Optional: Uncomment to set Network Security Rules on the VM. Only available if use_nic_nsg is set to true. 
    # security_rules = {
    #   test = {
    #   name                         = "Example"
    #   priority                     =  401
    #   access                       = "Allow"
    #   protocol                     = "Tcp"
    #   direction                    = "Inbound"
    #   source_port_ranges            = ["*"]
    #   source_address_prefixes      = [""]
    #   destination_port_ranges      = [""]
    #   destination_address_prefixes = [""]
    #   description = ""
    #   }
    # }
  }
}
