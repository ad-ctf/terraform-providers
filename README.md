# terraform-providers

Unified Terraform VM/DNS modules for provider-agnostic deployments.

## Repository Contents

### VM modules
- `vm/yandex` - creates one VM in Yandex Cloud.
- `vm/digitalocean` - creates one Droplet in DigitalOcean.
- `vm/timeweb` - creates one server in Timeweb Cloud with a Floating IP.

### DNS module
- `dns/cloudflare` - creates a set of `A` records in a Cloudflare zone.

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

Behavioral contract:
- the module manages one VM only;
- the module does not manage DNS directly;
- `vm_options` structure is provider-specific, but the semantics are the same: configuration for a single VM.

### Abstract DNS module (`dns/*`)

Purpose:
- create or update DNS records for IP addresses that are already known (often returned by VM modules).

Expected inputs:
- `provider_settings` (`object`) - DNS provider credentials and zone settings;
- `records` (`map(string)`) - mapping of `record_name -> IPv4`.

Outputs:
- no explicit Terraform outputs (the result is DNS records created/updated at the provider side).

Behavioral contract:
- the module does not create VMs or discover IPs by itself;
- the IP source is provided by the caller (for example, `module.vm.ip`);
- record policy (TTL/proxy/type) can be fixed inside a specific DNS module implementation.

### Typical Composition Flow

1. Call a `vm/*` module and read `module.<name>.ip`.
2. Pass that IP into a `dns/*` module through `records`.
3. Run `terraform plan/apply` in one stack.

## Supported Versions

- Current release: `v1.0.0` (see `CHANGELOG.md`).
- Consumers must pin module versions via `?ref=vX.Y.Z`.
- Using `main` as a module source is not recommended because interfaces may change without backward compatibility guarantees.

## Quick Start

```hcl
terraform {
  required_version = ">= 1.3.0"
}

module "vm" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/yandex?ref=v1.0.0"

  provider_settings = {
    yc_service_account_key_file = "/path/to/key.json"
    yc_cloud_id                 = "cloud-id"
    yc_folder_id                = "folder-id"
    yc_zone                     = "ru-central1-a"
    yc_network_name             = "default"
  }

  vm_name = "ctf-vm-01"

  vm_options = {
    image_family         = "ubuntu-2204-lts"
    cores                = 2
    memory               = 4
    disk_gb              = 20
    platform_id          = "standard-v2"
    core_fraction        = 100
    security_group_names = ["default-sg"]
  }

  cloud_config_content = <<-EOT
    #cloud-config
    users:
      - name: ctf
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ssh-ed25519 AAAA... example
  EOT
}

output "vm_ip" {
  value = module.vm.ip
}
```

## Module `vm/yandex`

Source:
```hcl
source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/yandex?ref=v1.0.0"
```

Creates a `yandex_compute_instance` in a selected zone and network.

### Input Variables

`provider_settings` (`object`, sensitive):
- `yc_service_account_key_file` (`string`) - path to service account JSON key file.
- `yc_cloud_id` (`string`) - cloud ID.
- `yc_folder_id` (`string`) - folder ID.
- `yc_zone` (`string`) - target VM zone.
- `yc_network_name` (`string`) - VPC network name used to select a subnet.

`vm_name` (`string`):
- VM resource name and hostname.

`vm_options` (`object`):
- `image_family` (`string`) - image family (`data.yandex_compute_image`).
- `cores` (`number`) - number of vCPUs.
- `memory` (`number`) - RAM in GB.
- `disk_gb` (`number`) - boot disk size in GB.
- `platform_id` (`string`, optional, default: `"standard-v2"`).
- `core_fraction` (`number`, optional).
- `nat_ip_address` (`string`, optional) - static public IP if needed.
- `security_group_names` (`list(string)`, optional, default: `[]`) - security group names.

`cloud_config_content` (`string`, sensitive):
- cloud-init content (`user-data` metadata field).

### Outputs

- `ip` - public IPv4 address of the VM.

### Notes

- The module automatically picks a subnet from `yc_network_name` in `yc_zone`.
- NAT is always enabled (`nat = true`).
- A lifecycle precondition checks that all `security_group_names` belong to the same network as `yc_network_name`.

## Module `vm/digitalocean`

Source:
```hcl
source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/digitalocean?ref=v1.0.0"
```

Creates one `digitalocean_droplet`.

### Input Variables

`provider_settings` (`object`):
- `digitalocean_api_token` (`string`) - DigitalOcean API token.

`vm_name` (`string`):
- Droplet name.

`vm_options` (`object`):
- `image` (`string`) - image slug or image ID.
- `region` (`string`) - region, for example `fra1`.
- `size` (`string`) - instance type, for example `s-1vcpu-2gb`.

`cloud_config_content` (`string`, sensitive):
- cloud-init for `user_data`.

### Outputs

- `ip` - public IPv4 address of the Droplet.

### Example

```hcl
module "vm_do" {
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
```

## Module `vm/timeweb`

Source:
```hcl
source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/timeweb?ref=v1.0.0"
```

Creates a `twc_server` and a dedicated `twc_floating_ip` attached to it.

### Input Variables

`provider_settings` (`object`, sensitive):
- `twc_token` (`string`) - Timeweb Cloud API token.

`vm_name` (`string`):
- server name and hostname.

`vm_options` (`object`):
- `location` (`string`) - location used in `twc_configurator`.
- `preset_type` (`string`) - configurator preset type.
- `os_name` (`string`) - OS name.
- `os_version` (`string`) - OS version.
- `availability_zone` (`string`) - availability zone.
- `disk_gb` (`number`) - disk size in GB (converted to MB internally).
- `cpu` (`number`) - number of vCPUs.
- `ram_mb` (`number`) - RAM in MB.

`cloud_config_content` (`string`, sensitive):
- cloud-init content (`cloud_init` field).

### Outputs

- `ip` - primary IPv4 address of the server.

### Example

```hcl
module "vm_twc" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/timeweb?ref=v1.0.0"

  provider_settings = {
    twc_token = var.twc_token
  }

  vm_name = "ctf-twc-01"

  vm_options = {
    location          = "ru-1"
    preset_type       = "cloud"
    os_name           = "ubuntu"
    os_version        = "22.04"
    availability_zone = "ru-1a"
    disk_gb           = 20
    cpu               = 2
    ram_mb            = 4096
  }

  cloud_config_content = file("${path.module}/cloud-init.yaml")
}
```

## Module `dns/cloudflare`

Source:
```hcl
source = "git::https://github.com/ad-ctf/terraform-providers.git//dns/cloudflare?ref=v1.0.0"
```

Creates `A` records with fixed `ttl = 60` and `proxied = false`.

### Input Variables

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

### VM + DNS Example

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

## Usage Recommendations

- Keep provider tokens in `*.tfvars` files or environment variables and mark them as sensitive in the root module.
- Validate changes with:
  - `terraform init`
  - `terraform validate`
  - `terraform plan`
- Upgrade pinned module versions deliberately (for example, `v1.0.0 -> v1.0.1`) and always review `plan` after updates.
