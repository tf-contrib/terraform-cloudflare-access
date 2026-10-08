# Who may sign in: these emails, and no one else.
resource "cloudflare_zero_trust_access_policy" "this" {
  account_id = var.account_id
  name       = "${var.name}: sign in"
  decision   = "allow"
  include    = [for email in var.emails : { email = { email = email } }]
}

# An Access for SaaS OIDC application, as a public client: the app proves
# itself with PKCE, and has no secret to keep. Access still generates one,
# returned only when the application is created, so it's in Terraform state;
# nothing uses it, and regenerating it in the dashboard once leaves state a
# dead one.
resource "cloudflare_zero_trust_access_application" "this" {
  account_id = var.account_id
  name       = var.name
  type       = "saas"

  app_launcher_visible      = false
  allowed_idps              = length(var.identity_provider_ids) > 0 ? var.identity_provider_ids : null
  auto_redirect_to_identity = length(var.identity_provider_ids) == 1

  saas_app = {
    auth_type = "oidc"
    # Refresh tokens need their own grant type as well as a lifetime: without
    # it, Access refuses offline_access ("refresh_tokens grant type is not
    # enabled").
    grant_types                      = concat(["authorization_code_with_pkce"], var.refresh_token_lifetime == null ? [] : ["refresh_tokens"])
    allow_pkce_without_client_secret = true
    redirect_uris                    = var.redirect_uris
    scopes                           = var.scopes

    access_token_lifetime = var.access_token_lifetime

    # Access's ID tokens last 5 minutes, whatever the access token lifetime:
    # refresh tokens are what keep a sign-in longer.
    refresh_token_options = var.refresh_token_lifetime == null ? null : { lifetime = var.refresh_token_lifetime }
  }

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.this.id
      precedence = 1
    },
  ]
}

locals {
  client_id = cloudflare_zero_trust_access_application.this.saas_app.client_id

  # Each Access for SaaS OIDC application is its own issuer, under the team's
  # domain: its discovery document is at <issuer>/.well-known/openid-configuration.
  # Access assigns the client ID, so there's none until the application exists.
  issuer = local.client_id == null ? null : "https://${var.team_name}.cloudflareaccess.com/cdn-cgi/access/sso/oidc/${local.client_id}"
}
