terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

variable "provider_settings" {
  description = "Cloudflare provider settings."
  type = object({
    cloudflare_api_token = string
    cloudflare_zone      = string
  })
  sensitive = true
}

variable "records" {
  description = "Map of DNS record names to IP addresses."
  type        = map(string)
}

provider "cloudflare" {
  api_token = var.provider_settings.cloudflare_api_token
}

data "cloudflare_zone" "target" {
  name = var.provider_settings.cloudflare_zone
}

resource "cloudflare_record" "dns_record" {
  for_each = var.records

  zone_id = data.cloudflare_zone.target.zone_id
  name    = each.key
  content = each.value
  type    = "A"
  ttl     = 60
  proxied = false
}
