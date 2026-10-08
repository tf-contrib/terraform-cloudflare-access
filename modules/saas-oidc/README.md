# saas-oidc

> An [Access for SaaS](https://developers.cloudflare.com/cloudflare-one/applications/configure-apps/saas-apps/generic-oidc-saas/)
> OIDC application for a public client, such as a CLI or a native app: people
> sign in to it through Cloudflare Access, with PKCE and no client secret, and
> it gets their ID token. Access is the issuer; your app, or a service it calls,
> verifies the token.

```hcl
module "cloudflare_access_saas_oidc" {
  source = "git::https://github.com/tofu-contrib/terraform-cloudflare-access.git//modules/saas-oidc?ref=v0.1.0" # x-release-please-version

  account_id    = var.account_id
  team_name     = "example" # example.cloudflareaccess.com
  name          = "example-cli"
  redirect_uris = ["http://127.0.0.1:8250/callback"]
  emails        = ["alice@example.com", "bob@example.com"]
}
```

The app signs in with the authorization code flow and PKCE, against the
discovery document at `<issuer>/.well-known/openid-configuration`, as
`client_id`. Whatever checks its ID tokens trusts `issuer`, with `client_id`
as the audience.

[cloudflare-sts](https://github.com/cf-contrib/cloudflare-sts) uses it to sign
people in to its CLI.

## What it creates

- **The application:** Access for SaaS, OIDC, as a public client. The app
  proves itself with PKCE (`authorization_code_with_pkce`, with
  `allow_pkce_without_client_secret`), so it has no secret to keep. Access
  sends the code only to `redirect_uris`, and grants `scopes`. It's hidden
  from the App Launcher. A sign-in lasts `token_lifetime`, 8h by default:
  Access's ID tokens expire with its access tokens, whose own default, 5m,
  would have people sign in again every five minutes.
- **Its policy:** the `emails` you give, and no one else, can sign in.
- **The issuer:** each Access for SaaS OIDC application is its own,
  `https://<team_name>.cloudflareaccess.com/cdn-cgi/access/sso/oidc/<client_id>`.
  Access assigns the client ID, so both are known only after apply.

Clients that keep a secret, such as a web app's backend, aren't supported yet.

## Prerequisites

- A Zero Trust organization on the account, with a team name: the free plan
  will do. Choosing a plan is a dashboard step.
- At least one login method in it, such as one-time PIN or GitHub. Pass their
  IDs as `identity_provider_ids` to allow only those; with exactly one, Access
  skips the choice.
- The deploy token needs **Account → Access: Apps and Policies: Edit**.

## After applying

Access generates a client secret for every OIDC application, and returns it
only when it's created, so it's in Terraform state. Nothing uses it: the app
signs in with PKCE alone. Regenerate it once in the dashboard (Zero Trust →
Access → Applications → the application → Edit) so the copy in state is a dead
one.

## Inputs

| Name | Required | Default | Description |
|---|---|---|---|
| `account_id` | yes | | Account with the Zero Trust organization. |
| `team_name` | yes | | The team name, as in `<team_name>.cloudflareaccess.com`. |
| `name` | yes | | The application's name, shown at sign-in, and its policy's prefix. |
| `redirect_uris` | yes | | Where Access may send the code: the app's callback. At least one. |
| `emails` | yes | | Who may sign in. At least one. |
| `token_lifetime` | no | `8h` | How long a sign-in lasts, `1m` to `24h`. Access's ID tokens expire with its access tokens. |
| `identity_provider_ids` | no | `[]` | The login methods allowed, by ID. Empty allows every one. |
| `scopes` | no | `["openid", "email", "profile"]` | The scopes the application grants. |

## Outputs

| Name | Description |
|---|---|
| `issuer` | The application's OIDC issuer. |
| `client_id` | The client ID the app signs in as, and its ID tokens' audience. |
| `application_id` | The Access application's ID. |

## Notes

- Tried end to end against Access, with one-time PIN: its ID tokens carry
  `email`, `sub`, and the application's `iss`, and with Access's default access
  token lifetime they expired after 5 minutes.
- `tofu test` plans the module with a mocked provider: the application's
  settings, the policy, the login methods, and the input checks. Access
  assigns the client ID, so the issuer built from it is Cloudflare's
  documented format rather than tested.
