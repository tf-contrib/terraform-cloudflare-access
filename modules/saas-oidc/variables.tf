variable "account_id" {
  type        = string
  description = "Cloudflare account ID, with a Zero Trust organization: the application and its policy are created here."
}

variable "team_name" {
  type        = string
  description = "The Zero Trust organization's team name, as in <team_name>.cloudflareaccess.com: the issuer's host."

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.team_name))
    error_message = "team_name must be the bare team name, such as example for example.cloudflareaccess.com."
  }
}

variable "name" {
  type        = string
  description = "The Access application's name, shown at sign-in, and its policy's prefix."

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name must not be empty."
  }
}

variable "redirect_uris" {
  type        = list(string)
  description = "Where Access may send the authorization code: the app's callback, such as http://127.0.0.1:8250/callback for a CLI that listens on a local port."

  validation {
    condition     = length(var.redirect_uris) > 0
    error_message = "redirect_uris must name at least one callback."
  }
}

variable "emails" {
  type        = list(string)
  description = "Who may sign in: the Access policy lets in these emails and no one else."

  validation {
    condition     = length(var.emails) > 0
    error_message = "emails must name at least one person."
  }
}

variable "token_lifetime" {
  type        = string
  description = "How long a sign-in lasts: the application's access token lifetime, which its ID tokens follow. Minutes or hours, from 1m to 24h. Access's own default is 5m."
  default     = "8h"

  validation {
    # In minutes, 1 to 1440: a malformed value isn't a number of them at all.
    condition = try(alltrue([
      for minutes in [tonumber(regex("^([0-9]+)[mh]$", var.token_lifetime)[0]) * (endswith(var.token_lifetime, "h") ? 60 : 1)] :
      minutes >= 1 && minutes <= 1440
    ]), false)
    error_message = "token_lifetime must be minutes or hours, such as 30m or 8h, from 1m to 24h."
  }
}

variable "identity_provider_ids" {
  type        = list(string)
  description = "The Access login methods people may use, by ID: one-time PIN, GitHub, and so on. Empty allows every one the organization has; exactly one skips the choice."
  default     = []
}

variable "scopes" {
  type        = list(string)
  description = "The OIDC scopes the application grants."
  default     = ["openid", "email", "profile"]
}
