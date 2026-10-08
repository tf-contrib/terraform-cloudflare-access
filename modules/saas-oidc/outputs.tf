output "issuer" {
  value       = local.issuer
  description = "The application's OIDC issuer: its discovery document is at <issuer>/.well-known/openid-configuration."
}

output "client_id" {
  value       = local.client_id
  description = "The application's client ID, which the app signs in as, and its ID tokens' audience."
}

output "application_id" {
  value       = cloudflare_zero_trust_access_application.this.id
  description = "The Access application's ID."
}
