config {
  call_module_type = "local"
  force            = false
}

# Note: the tflint-ruleset-azurerm plugin is intentionally omitted — this is a
# wrapper module that passes all config via a `type = any` variable, so attribute-level
# validation rules produce false positives for every resource argument.

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}
