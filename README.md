# terraform-cloudflare-access

[![CI](https://github.com/tofu-contrib/terraform-cloudflare-access/actions/workflows/ci.yml/badge.svg)](https://github.com/tofu-contrib/terraform-cloudflare-access/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/tofu-contrib/terraform-cloudflare-access?include_prereleases)](https://github.com/tofu-contrib/terraform-cloudflare-access/releases)
[![License](https://img.shields.io/badge/License-MPL--2.0-brightgreen.svg)](LICENSE)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-compatible-FFDA18?logo=opentofu&logoColor=black)](https://opentofu.org)

[OpenTofu](https://opentofu.org) and Terraform modules for
[Cloudflare Access](https://developers.cloudflare.com/cloudflare-one/policies/access/).

Each kind of Access resource is a module of its own, under
[`modules/`](modules), with only the inputs that kind needs. The root module
creates nothing.

## Modules

None yet.

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
