# test_dependencies.tf
# Self-contained dependency resources, owned entirely by this harness.
#
# Deliberately NOT reusing any shared/production resource group, vnet, or
# subnet: writing into a shared L1-managed "Network" RG usually requires
# elevated, L1-scoped permissions. A dedicated throwaway RG + vnet + subnet
# here needs only Contributor on the sandbox subscription and can never
# collide with or affect any production resource.
#
# Names are suffixed with var.pr_number so concurrently open PRs against this
# module never collide on the same sandbox subscription.

resource "azurerm_resource_group" "live_test" {
  name     = "${var.env}-caf-windows-vmv2-live-test-${var.pr_number}-rg"
  location = var.location

  # pr-number tag: lets the nightly orphan sweeper find this RG by tag and
  # match it back to a PR, independent of naming convention.
  # repository tag: the sandbox subscription is shared across module repos,
  # so the sweeper must scope its pr-number matches to only this repo's own
  # PRs - otherwise a PR number collision across repos could misclassify (or
  # destroy) another repo's live resource group.
  tags = {
    "pr-number"  = var.pr_number
    "repository" = var.repository
  }
}

resource "azurerm_virtual_network" "live_test" {
  name                = "${var.env}-caf-windows-vmv2-live-test-${var.pr_number}-vnet"
  address_space       = ["10.253.0.0/16"] # arbitrary, unpeered - collision-safe by construction
  location            = azurerm_resource_group.live_test.location
  resource_group_name = azurerm_resource_group.live_test.name
}

resource "azurerm_subnet" "live_test" {
  name                 = "${var.env}-caf-windows-vmv2-live-test-${var.pr_number}-snet"
  resource_group_name  = azurerm_resource_group.live_test.name
  virtual_network_name = azurerm_virtual_network.live_test.name
  address_prefixes     = ["10.253.0.0/24"]
}

locals {
  # windows_virtual_machineV2 takes MAPS keyed by the name the windows_VM
  # object references (resource_group = "Project", nic.subnet = "livetest").
  #
  # Keyvault is required even though admin_password is always supplied here
  # (skipping the actual KV data source lookup, count=0): secret.tf's
  # locals.kv_sha unconditionally hashes var.resource_groups["Keyvault"].id
  # regardless of that count - a real Key Vault never needs to exist behind
  # it since the hash is just of the RG id string, but the map key itself
  # must resolve or the plan fails with "Invalid index" before count is even
  # evaluated. Real ESLZ callers never hit this because their resource_groups
  # map always includes every subscription RG (Keyvault included).
  resource_groups = {
    Project  = { name = azurerm_resource_group.live_test.name, id = azurerm_resource_group.live_test.id }
    Keyvault = { name = azurerm_resource_group.live_test.name, id = azurerm_resource_group.live_test.id }
  }
  subnets = {
    livetest = { id = azurerm_subnet.live_test.id }
  }
}
