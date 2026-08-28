variable "env" {
  description = "(Required) 4 character string defining the environment name prefix for the VM"
  type        = string
  default     = "livetest"
}

variable "group" {
  description = "(Required) Character string defining the group for the target subscription"
  type        = string
  default     = "livetest"
}

variable "project" {
  description = "(Required) Character string defining the project for the target subscription"
  type        = string
  default     = "livetest"
}

variable "location" {
  description = "Location for the throwaway live-test resource group (+ vnet/subnet)"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags applied to the resources created by this harness"
  type        = map(string)
  default = {
    purpose = "module-live-test"
  }
}

variable "pr_number" {
  description = <<-EOT
    Suffix applied to test_dependencies.tf resource names so concurrent PRs
    against this module never collide on the same sandbox subscription. CI
    sources this from `TF_VAR_pr_number` (`github.event.number`); manual runs
    can leave the default or pass their own value.
  EOT
  type        = string
  default     = "manual"
}

variable "repository" {
  description = "This repo's own org/name slug - tags the live-test resource group so the shared-subscription sweeper only ever matches this repo's own PRs"
  type        = string
  default     = "canada-ca-terraform-modules/terraform-azurerm-caf-windows_virtual_machineV2"
}

variable "windows_VMs" {
  description = "Map of windows VM configuration objects, keyed by userDefinedString (mirrors the module's own ESLZ/SRV-Windows.tf calling convention)"
  type        = any
  default     = {}
}
