locals {
  custom_data_url = strcontains(var.env, "G3") ? "https://g3scexample01ba8b7d81.blob.core.windows.net/testest/testtest.ps1" : "https://gcpcenteslzpublicblob4df.blob.core.windows.net/publicresources/windows-all-customdata-default.ps1"
}

data "http" "custom_data" {
  count = var.custom_data == "install-ca-certs" ? 1 : 0
  url = local.custom_data_url
}