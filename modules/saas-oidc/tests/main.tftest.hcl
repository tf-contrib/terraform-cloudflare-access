# Plans the module with a mocked provider: no credentials or network needed.
# Covers the application as a public client with PKCE, who may sign in, and
# the login methods. The client ID is Access's, so it's unknown until apply,
# and the mock can't make one up inside saas_app: the issuer built from it is
# Cloudflare's documented
# https://<team>.cloudflareaccess.com/cdn-cgi/access/sso/oidc/<client-id>.
mock_provider "cloudflare" {}

variables {
  account_id    = "0123456789abcdef0123456789abcdef"
  team_name     = "example"
  name          = "example-cli"
  redirect_uris = ["http://127.0.0.1:8250/callback"]
  emails        = ["alice@example.com", "bob@example.com"]
}

run "is_a_public_pkce_client" {
  command = plan

  assert {
    condition     = cloudflare_zero_trust_access_application.this.type == "saas"
    error_message = "the application should be Access for SaaS"
  }

  assert {
    condition = (
      cloudflare_zero_trust_access_application.this.saas_app.auth_type == "oidc" &&
      tolist(cloudflare_zero_trust_access_application.this.saas_app.grant_types) == tolist(["authorization_code_with_pkce"]) &&
      cloudflare_zero_trust_access_application.this.saas_app.allow_pkce_without_client_secret
    )
    error_message = "the application should be an OIDC public client: PKCE, and no client secret"
  }

  assert {
    condition     = cloudflare_zero_trust_access_application.this.name == "example-cli" && cloudflare_zero_trust_access_policy.this.name == "example-cli: sign in"
    error_message = "the application and its policy should take name"
  }

  assert {
    condition     = tolist(cloudflare_zero_trust_access_application.this.saas_app.redirect_uris) == tolist(["http://127.0.0.1:8250/callback"])
    error_message = "the redirects should be redirect_uris"
  }

  assert {
    condition     = toset(cloudflare_zero_trust_access_application.this.saas_app.scopes) == toset(["openid", "email", "profile"])
    error_message = "the scopes should default to openid, email and profile"
  }
}

run "keeps_the_access_defaults" {
  command = plan

  assert {
    condition     = cloudflare_zero_trust_access_application.this.saas_app.access_token_lifetime == "5m"
    error_message = "the access token should last Access's default, 5m"
  }

  assert {
    condition     = cloudflare_zero_trust_access_application.this.saas_app.refresh_token_options == null
    error_message = "without refresh_token_lifetime, there should be no refresh tokens"
  }
}

run "takes_an_access_token_lifetime" {
  command = plan

  variables {
    access_token_lifetime = "30m"
  }

  assert {
    condition     = cloudflare_zero_trust_access_application.this.saas_app.access_token_lifetime == "30m"
    error_message = "access_token_lifetime should set the access token lifetime"
  }
}

run "rejects_an_access_token_lifetime_over_a_day" {
  command = plan

  variables {
    access_token_lifetime = "25h"
  }

  expect_failures = [var.access_token_lifetime]
}

run "rejects_an_access_token_lifetime_in_seconds" {
  command = plan

  variables {
    access_token_lifetime = "300s"
  }

  expect_failures = [var.access_token_lifetime]
}

run "keeps_a_sign_in_with_refresh_tokens" {
  command = plan

  variables {
    refresh_token_lifetime = "7d"
  }

  assert {
    condition     = cloudflare_zero_trust_access_application.this.saas_app.refresh_token_options.lifetime == "7d"
    error_message = "refresh_token_lifetime should set the refresh tokens' lifetime"
  }
}

run "rejects_a_refresh_token_lifetime_of_a_minute" {
  command = plan

  variables {
    refresh_token_lifetime = "1m"
  }

  expect_failures = [var.refresh_token_lifetime]
}

run "rejects_a_refresh_token_lifetime_in_weeks" {
  command = plan

  variables {
    refresh_token_lifetime = "1w"
  }

  expect_failures = [var.refresh_token_lifetime]
}

run "lets_in_only_the_given_emails" {
  command = plan

  assert {
    condition = (
      cloudflare_zero_trust_access_policy.this.decision == "allow" &&
      toset([for rule in cloudflare_zero_trust_access_policy.this.include : rule.email.email]) == toset(["alice@example.com", "bob@example.com"])
    )
    error_message = "the policy should allow exactly the given emails"
  }

  assert {
    condition     = cloudflare_zero_trust_access_application.this.policies[0].id == cloudflare_zero_trust_access_policy.this.id
    error_message = "the application should use the policy"
  }
}

run "outputs_the_application" {
  command = plan

  assert {
    condition     = output.application_id == cloudflare_zero_trust_access_application.this.id
    error_message = "application_id should be the application's ID"
  }
}

run "allows_every_login_method_by_default" {
  command = plan

  assert {
    condition     = cloudflare_zero_trust_access_application.this.allowed_idps == null && !cloudflare_zero_trust_access_application.this.auto_redirect_to_identity
    error_message = "without identity_provider_ids, every login method should be offered"
  }
}

run "skips_the_choice_with_one_login_method" {
  command = plan

  variables {
    identity_provider_ids = ["99999999-8888-7777-6666-555555555555"]
  }

  assert {
    condition = (
      cloudflare_zero_trust_access_application.this.allowed_idps == toset(["99999999-8888-7777-6666-555555555555"]) &&
      cloudflare_zero_trust_access_application.this.auto_redirect_to_identity
    )
    error_message = "with one login method, it should be the only one and go straight to it"
  }
}

run "rejects_a_team_domain" {
  command = plan

  variables {
    team_name = "example.cloudflareaccess.com"
  }

  expect_failures = [var.team_name]
}

run "rejects_no_one" {
  command = plan

  variables {
    emails = []
  }

  expect_failures = [var.emails]
}

run "rejects_no_redirect_uris" {
  command = plan

  variables {
    redirect_uris = []
  }

  expect_failures = [var.redirect_uris]
}

run "rejects_an_empty_name" {
  command = plan

  variables {
    name = " "
  }

  expect_failures = [var.name]
}
