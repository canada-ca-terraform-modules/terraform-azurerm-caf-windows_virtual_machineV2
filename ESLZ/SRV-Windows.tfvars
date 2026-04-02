windows_VMs = {
  test = {
    serverType     = "SWJ"
    resource_group = "Project"
    admin_username = "azureadmin"
    # admin_password = "Canada123!"  # Optional: Only set the password if a generated password cannot be created. See README for details
    vm_size = "Standard_D2s_v5"

    # backup_policy = "daily1"  # Optional: name or ARM resource ID of the backup policy.
    #   Regular VMs: accepts a name (resolved to ARM ID via data source) or a full ARM ID
    #   jump_server = true:  MUST be a full ARM resource ID — no data source lookup is performed
    # disable_backup = false    # Optional: Set to true to skip backup entirely    
    automatic_updates_enabled = true # (Optional) azurerm 4.x — controls Windows automatic updates. Defaults to true.
    # enable_automatic_updates = true # Legacy alias — still accepted for backward compatibility
    patch_assessment_mode = "AutomaticByPlatform" # force settings to AutomaticByPlatform for UMC OS patching 
    patch_mode            = "AutomaticByPlatform" # force settings to AutomaticByPlatform for UMC OS patching 

    custom_data = "install-ca-certs"
    # computer_name          = "Example"                                           # Optional: Set this if you need the guest OS Hostname to be different than the Azure resource name
    # user_data              = "post_install_scripts/ubuntu/post_install.sh"       # Optional: Set this value with the relative path to the file from your CWD.
    # boot_diagnostic        = true
    # use_nic_nsg            = true

    # At least one nic is required. If more than one is present, the first nic in the list will be the primary one.
    nic = {
      nic1 = {
        subnet                        = "OZ"
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

    # write_accelerator_enabled = false  # Optional: top-level arg — enables write accelerator on the OS disk (requires Premium storage + caching=None)

    # Optional: Uncomment if you need to configure os_disk with different defaults than below. Only supports one os_disk
    # os_disk = {
    #   caching              = "ReadWrite"
    #   storage_account_type = "StandardSSD_LRS"
    #   disk_size_gb         = 256
    # }

    # Optional: Uncomment and configure data disks for the VM. Can create more than one data disks.
    # data_disks = {
    #   disk1 = {
    #     storage_account_type = "StandardSSD_LRS"
    #     disk_create_option = "Empty"
    #     disk_size_gb = 500
    #     lun = 0
    #     caching = "ReadWrite"
    #   }
    # }

    # Optional: Uncomment this block to setup auto-shutdown on the VM.
    # auto_shutdown_config = {
    #   enabled               = true
    #   timezone              = "Eastern Standard Time"
    #   daily_recurrence_time = "1600"

    #   notification_settings = {
    #     enabled = false
    #     email = ""
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
    # keyvault = {
    #   name                = ""
    #   resource_group_name = "Keyvault"
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
