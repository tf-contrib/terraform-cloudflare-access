# Changelog

## [0.2.0](https://github.com/tf-contrib/terraform-cloudflare-access/compare/v0.1.0...v0.2.0) (2026-10-08)


### ⚠ BREAKING CHANGES

* token_lifetime is now access_token_lifetime, defaulting to Access's own 5m: it sets the access token's lifetime, not the sign-in's. Set refresh_token_lifetime to keep a sign-in longer.

### Features

* keep a sign-in with refresh tokens ([27807bc](https://github.com/tf-contrib/terraform-cloudflare-access/commit/27807bc52994351feab0df005fc72442dc29eb2d))

## 0.1.0 (2026-10-08)


### Features

* saas-oidc, an Access for SaaS OIDC application for a public client ([#1](https://github.com/tofu-contrib/terraform-cloudflare-access/issues/1)) ([edfc3ed](https://github.com/tofu-contrib/terraform-cloudflare-access/commit/edfc3ed5887834c7a18817b9d6261cd468578f06))
