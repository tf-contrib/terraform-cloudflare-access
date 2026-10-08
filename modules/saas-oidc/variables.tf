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

variable "access_token_lifetime" {
  type        = string
  description = "The application's access token lifetime, minutes or hours from 1m to 24h: Access's own default is 5m. It doesn't make a sign-in last longer: Access's ID tokens expire after 5 minutes whatever it is. For that, set refresh_token_lifetime."
  default     = "5m"

  validation {
    # In minutes, 1 to 1440: a malformed value isn't a number of them at all.
    condition = try(alltrue([
      for minutes in [tonumber(regex("^([0-9]+)[mh]$", var.access_token_lifetime)[0]) * (endswith(var.access_token_lifetime, "h") ? 60 : 1)] :
      minutes >= 1 && minutes <= 1440
    ]), false)
    error_message = "access_token_lifetime must be minutes or hours, such as 30m or 8h, from 1m to 24h."
  }
}

variable "refresh_token_lifetime" {
  type        = string
  description = "How long a sign-in lasts, minutes, hours or days, longer than 1m, such as 7d: Access then issues refresh tokens (it adds the offline_access scope), which the app trades for new ID tokens without signing in again, each checked against the policy. Keep it under the organization's session duration, which otherwise wins. null issues none, and a sign-in lasts as long as its ID token, 5 minutes."
  default     = null

  validation {
    # In minutes, over 1: a malformed value isn't a number of them at all.
    condition = var.refresh_token_lifetime == null || try(alltrue([
      for minutes in [tonumber(regex("^([0-9]+)[mhd]$", var.refresh_token_lifetime)[0]) * lookup({ m = 1, h = 60, d = 1440 }, substr(var.refresh_token_lifetime, -1, 1))] :
      minutes > 1
    ]), false)
    error_message = "refresh_token_lifetime must be minutes, hours or days longer than 1m, such as 8h or 7d, or null."
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
