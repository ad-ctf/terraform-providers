# Module `dns/cloudflare`

Creates `A` records with fixed `ttl = 60` and `proxied = false`.

## Provider setup

1. Open https://dash.cloudflare.com/profile/api-tokens
2. Click "Create Token", use "Edit zone DNS" template.
3. Zone Resources: "Include Specific Zone [select your zone]". Leave all other options as is. Token name does not matter, come up with something memorable.
4. Create token and copy it, specify in `cloudflare_api_token` module input.

## VM + DNS Example

```hcl
module "vm" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/digitalocean?ref=v1.0.0"
  # ...
}

module "dns" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//dns/cloudflare?ref=v1.0.0"

  provider_settings = {
    cloudflare_api_token = var.cloudflare_api_token
    cloudflare_zone      = "example.com"
  }

  records = {
    "ctf" = module.vm.ip
  }
}
```

## Input Variables

`provider_settings` (`object`, sensitive):
- `cloudflare_api_token` (`string`) - Cloudflare API token.
- `cloudflare_zone` (`string`) - DNS zone name, for example `example.com`.

`records` (`map(string)`):
- key - record name;
- value - IPv4 address.

Example map:

```hcl
records = {
  "www" = "203.0.113.10"
  "api" = "203.0.113.11"
  "@"   = "203.0.113.12"
}
```
