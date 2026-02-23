# terraform-providers

Terraform modules for AD CTF infrastructure.

## Modules
- `vm/yandex`
- `vm/digitalocean`
- `vm/timeweb`
- `dns/cloudflare`

## Usage
```hcl
module "vm" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/yandex?ref=v1.0.0"
  # ...
}

module "dns" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//dns/cloudflare?ref=v1.0.0"
  # ...
}
```

## Versioning
- Consumers must pin a semver tag in `?ref=vX.Y.Z`.
- `main` is not a stable interface for consumption.
