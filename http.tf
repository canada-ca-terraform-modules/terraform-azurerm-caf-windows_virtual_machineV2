locals {
  custom_data_default_url = strcontains(var.env, "G3") ? "https://g3pceslzresentdfa0353e.blob.core.windows.net/publicresources/windows-all-customdata-default.ps1" : "https://gcpcenteslzpublicblob4df.blob.core.windows.net/publicresources/windows-all-customdata-default.ps1"

  # custom_data may be the legacy "install-ca-certs" alias, an arbitrary http(s) URL to fetch, or an already-encoded/plain value
  custom_data_is_url = try(startswith(var.custom_data, "http://"), false) || try(startswith(var.custom_data, "https://"), false)
  custom_data_fetch  = var.custom_data == "install-ca-certs" || local.custom_data_is_url
  custom_data_url    = var.custom_data == "install-ca-certs" ? local.custom_data_default_url : var.custom_data
}

data "http" "custom_data" {
  count = local.custom_data_fetch ? 1 : 0
  url   = local.custom_data_url
}
