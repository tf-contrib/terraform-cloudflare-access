# terraform-cloudflare-access

[![CI](https://github.com/tf-contrib/terraform-cloudflare-access/actions/workflows/ci.yml/badge.svg)](https://github.com/tf-contrib/terraform-cloudflare-access/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/tf-contrib/terraform-cloudflare-access?include_prereleases)](https://github.com/tf-contrib/terraform-cloudflare-access/releases)
[![License](https://img.shields.io/badge/License-MPL--2.0-brightgreen.svg)](LICENSE)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-compatible-FFDA18?logo=opentofu&logoColor=black)](https://opentofu.org)

[OpenTofu](https://opentofu.org) and Terraform modules for
[Cloudflare Access](https://developers.cloudflare.com/cloudflare-one/policies/access/).

Each kind of Access resource is a module of its own, under
[`modules/`](modules), with only the inputs that kind needs. The root module
creates nothing.

## Modules

| Module | What it creates |
|---|---|
| [`saas-oidc`](modules/saas-oidc) | An Access for SaaS OIDC application for a public client, such as a CLI or a native app, and the policy that says who may sign in. Outputs its issuer and client ID. |

Use a module by its path and a release:

```hcl
module "cloudflare_access_saas_oidc" {
  source = "git::https://github.com/tf-contrib/terraform-cloudflare-access.git//modules/saas-oidc?ref=v0.2.0" # x-release-please-version
  # ...
}
```

Every module is released together, on one version. Before 1.0, a minor
version may change inputs; the changelog says how.

## Development

```sh
nix develop                     # OpenTofu
tofu fmt -recursive
tofu -chdir=modules/<module> init -backend=false && tofu -chdir=modules/<module> test
```

The tests plan each module with a mocked provider: no Cloudflare account or
credentials needed.

## License

[MPL-2.0](LICENSE)
