# Wired to .github/workflows/live-test.yml (see that PR for the workflow
# file itself - split into two PRs per the module-live-test-conversion skill
# to avoid the "Baseline apply checks out the target branch" chicken-and-egg
# problem).
terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }

  # Empty on purpose: the state file path is supplied at `terraform init`
  # time via `-backend-config="path=..."` (partial configuration), so the
  # target-branch checkout and the PR-branch checkout can point at the same
  # external state file without either owning its own local state.
  backend "local" {}
}

provider "azurerm" {
  storage_use_azuread             = true
  resource_provider_registrations = "legacy"
  features {}
}

module "windows_VMs" {
  # PR code and baseline code are two on-disk checkouts of this same repo,
  # not two resolved git refs - no pinned ?ref, no version toggle here.
  source = "../../"

  for_each = var.windows_VMs

  location          = var.location
  env               = var.env
  group             = var.group
  project           = var.project
  userDefinedString = each.key
  windows_VM        = each.value
  resource_groups   = local.resource_groups # from test_dependencies.tf
  subnets           = local.subnets         # from test_dependencies.tf
  tags              = var.tags
}
