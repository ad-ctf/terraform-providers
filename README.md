# terraform-providers

Unified Terraform VM/DNS modules for provider-agnostic deployments. Tired of finding out which cloud resources you need to deploy a simple VM with public IP? Just make a config and pass it to one of this modules!

## Repository Contents

Provider-specific setup is documented in the README of the corresponding module.

### VM modules

- [`vm/yandex`](./vm/yandex) - [Yandex Cloud](https://yandex.cloud/).
- [`vm/digitalocean`](./vm/digitalocean) - [DigitalOcean](https://www.digitalocean.com/).
- [`vm/timeweb`](./vm/timeweb) - [Timeweb](https://timeweb.cloud/).

### DNS module

- [`dns/cloudflare`](./dns/cloudflare) - [Cloudflare](./dns/cloudflare).

## Quick Start

```hcl
terraform {
  required_version = ">= 1.3.0"
}

module "vm" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/digitalocean?ref=v1.0.0"

  provider_settings = {
    digitalocean_api_token = var.digitalocean_api_token
  }

  vm_name = "ctf-do-01"

  vm_options = {
    image  = "ubuntu-22-04-x64"
    region = "fra1"
    size   = "s-1vcpu-2gb"
  }

  cloud_config_content = file("${path.module}/cloud-init.yaml")
}

output "vm_ip" {
  value = module.vm.ip
}

module "dns" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//dns/cloudflare?ref=v1.0.0"

  provider_settings = {
    cloudflare_api_token = var.cloudflare_api_token
    cloudflare_zone      = "example.com"
  }

  records = {
    "@" = module.vm.ip
  }
}
```

## General Module Contract

This section describes the abstract interface you can rely on when using modules from this repository.

### Abstract VM module (`vm/*`)

Purpose:

- create exactly one virtual machine in a specific provider;
- apply cloud-init configuration;
- return a public IPv4 address for downstream automation.

Expected inputs:

- `provider_settings` (`object`) - provider-specific credentials and environment settings (tokens, cloud/folder/zone, etc.);
- `vm_name` (`string`) - resource name and hostname;
- `vm_options` (`object`) - provider-specific VM configuration (image, size, region/zone, disk, CPU/RAM, etc.);
- `cloud_config_content` (`string`, usually sensitive) - cloud-init content.

Outputs:

- `ip` (`string`) - public IPv4 address of the created VM.

### Abstract DNS module (`dns/*`)

Purpose:

- create or update DNS records for IP addresses that are already known (often returned by VM modules).

Expected inputs:

- `provider_settings` (`object`) - DNS provider credentials and zone settings;
- `records` (`map(string)`) - mapping of `record_name -> IPv4`.

Outputs:

- no explicit Terraform outputs (the result is DNS records created/updated at the provider side).

## Supported Versions

- Current release: `v1.0.0` (see `CHANGELOG.md`).
- Consumers must pin module versions via `?ref=vX.Y.Z`.
- Using `main` as a module source is not recommended because interfaces may change without backward compatibility guarantees.

## Thanks to

- [fanbrawla](https://github.com/fanbrawla), yandex module developer