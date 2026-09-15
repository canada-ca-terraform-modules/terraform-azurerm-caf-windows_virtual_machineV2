variable "location" {
  description = "Azure location for the VM"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags that will be applied to every associated VM resource"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "(Required) 4 character string defining the environment name prefix for the VM"
  type        = string
}

variable "group" {
  description = "(Required) Character string defining the group for the target subscription"
  type        = string
}

variable "project" {
  description = "(Required) Character string defining the project for the target subscription"
  type        = string
}

variable "userDefinedString" {
  description = "(Required) User defined portion value for the name of the VM."
  type        = string
}

variable "windows_VM" {
  description = "Object containing all VM parameters"
  type        = any
  default     = {}
}

variable "resource_groups" {
  description = "(Required) Resource group object for the VM"
  type        = any
  default     = {}
}

variable "subnets" {
  description = "(Required) List of subnet objects for the VM"
  type        = any
}

variable "user_data" {
  description = "Base64 encoded file representing user data script for the VM"
  type        = any
  default     = null
}

variable "custom_data" {
  description = "Base64 encoded file representing user data script for the VM. Also accepts the legacy \"install-ca-certs\" alias, or an http(s) URL pointing to a script to fetch and use as custom data"
  type        = any
  default     = null
}
