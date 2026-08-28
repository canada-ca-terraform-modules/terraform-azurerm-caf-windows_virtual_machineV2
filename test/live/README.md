# `test/live/` - live-test harness

A live, real-Azure-resource harness used by the `live-test` PR check (see
the [`live-test-actions`](https://github.com/canada-ca-terraform-modules/live-test-actions)
repo and this module's own `.github/workflows/live-test.yml`) to prove that
an open PR doesn't destroy or replace a resource a real consumer already has
running. It is **not** a substitute for either of the module's other two
test surfaces:

- **`tests/*.tftest.hcl`** - mock-based unit tests (`terraform test`, no
  provider credentials, no live Azure resources). Covers naming, defaults,
  and validation logic on every PR via `terraform-ci.yml`. Run these first;
  they're fast and free.
- **`ESLZ/`** - the usage example (`SRV-Windows.tf`) showing the map-based
  (`for_each`) blueprint pattern consumers actually wire this module into.
  Not exercised by CI at all; documentation only. This harness's `main.tf`
  mirrors that same calling convention (`module "windows_VMs"`, `for_each`
  over a map keyed by `userDefinedString`) rather than inventing a different
  shape.
- **`test/live/`** (this directory) - a single, real instance of the module
  applied against a disposable Azure sandbox subscription. Used by CI to
  diff the PR's plan against a live baseline, and can be run manually by a
  maintainer the same way.

## What's here

| File | Purpose |
|---|---|
| `main.tf` | Module block with `source = "../../"` (a relative path, not a pinned `?ref` - "baseline" and "PR" are just two on-disk checkouts of this repo), the `azurerm` provider config, and an empty `backend "local" {}` block (path supplied at `init` time - see below). |
| `test_dependencies.tf` | A dedicated, throwaway resource group + vnet + subnet this harness owns outright - never a shared/production resource. Names are suffixed with `var.pr_number` so concurrently open PRs never collide. |
| `variables.tf` | `env`, `group`, `project`, `location` (defaults to `canadacentral`), `tags`, `pr_number` (defaults to `"manual"`), `repository`, and `windows_VMs` (typed `any`, a map keyed by `userDefinedString`, fanned out via `for_each` in `main.tf`). |
| `config/windows_virtual_machineV2.tfvars` | One representative fixture: a single minimal Windows VM (NIC only, no NSG/ASG/availability set/data disks/boot diagnostics/backup), `jump_server = true` + `disable_backup = true` to skip the Recovery Services Vault lookups this sandbox subscription has no vault for, `vm_size = "Standard_D2as_v6"` (Dav6 family - required in this sandbox; see repo-level skill notes on `Dsv5`/`Dasv5` capacity restrictions). |

No Terragrunt anywhere under this directory - a single harness per repo has
no cross-harness DRY need.

## Running it manually

Requires your own `az login` session against the sandbox subscription (CI
uses OIDC instead).

```bash
cd test/live
terraform init
terraform plan  -var-file=config/windows_virtual_machineV2.tfvars
terraform apply -var-file=config/windows_virtual_machineV2.tfvars
```

Confirm only the live-test resource group/vnet/subnet and
`module.windows_VMs["livetest"]` are planned/applied, then tear it down:

```bash
terraform destroy -var-file=config/windows_virtual_machineV2.tfvars
```

No `.tfstate` file is ever committed under `test/live/` - every run is
fully ephemeral, whether run by CI or by hand.

## Two-checkout state isolation (baseline vs. PR)

CI proves a PR isn't a breaking change by applying the target branch as a
live baseline, then plan/apply-ing the PR branch's checkout of this same
harness against that same live state - two on-disk checkouts of this repo,
one shared external state file, no state copying between them. See
`.github/workflows/live-test.yml` for the exact steps; `pr_number`
(`TF_VAR_pr_number` in CI, sourced from `github.event.number`) suffixes
every `test_dependencies.tf` resource name, so two concurrently open PRs
against this module - each pointed at their own
`live-test-<pr-number>.tfstate` - never collide on the same sandbox resource
group.
