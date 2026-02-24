# Module `vm/timeweb`

Creates a `twc_server` and a dedicated `twc_floating_ip` attached to it.

> :warning: **WARNING:** Timeweb requires to have enough balance for the whole month to run third and subsequent VMs. Consider using other providers for large deployments.

## Provider Setup

1. Open https://timeweb.cloud/my/api-keys/create
2. Specify token name (any of your choice) and expiration. Leave another options as is.
3. Create and copy the token, specify in `twc_token` module input.

## Example

```hcl
module "vm_twc" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/timeweb?ref=v1.0.0"

  provider_settings = {
    twc_token = var.twc_token
  }

  vm_name = "ctf-twc-01"

  vm_options = {
    location          = "ru-1"
    preset_type       = "standard"
    os_name           = "ubuntu"
    os_version        = "22.04"
    availability_zone = "spb-3"
    disk_gb           = 15
    cpu               = 2
    ram_mb            = 2048
  }

  cloud_config_content = file("${path.module}/cloud-init.yaml")
}
```

## Input Variables

`provider_settings` (`object`, sensitive):
- `twc_token` (`string`) - Timeweb Cloud API token.

`vm_name` (`string`):
- server name and hostname.

`vm_options` (`object`):
- `location` (`string`) - see list of locations below.
- `preset_type` (`string`) - configurator preset type (`premium`, `standard`, `high_cpu`).
- `os_name` (`string`) - OS name (see list of OS names and versions below).
- `os_version` (`string`) - OS version.
- `availability_zone` (`string`) - availability zone (see list below).
- `disk_gb` (`number`) - disk size in GB.
- `cpu` (`number`) - number of vCPUs.
- `ram_mb` (`number`) - RAM in MB.

`cloud_config_content` (`string`, sensitive):
- cloud-init content.

## Outputs

- `ip` - primary IPv4 address of the server.

## Locations & Availability Zones

https://timeweb.cloud/api-docs#tag/Lokacii/operation/getLocations

```
{
  "locations": [
    {
      "location": "ru-1",
      "location_code": "RU",
      "availability_zones": [
        "spb-1",
        "spb-5",
        "spb-2",
        "spb-3",
        "spb-4"
      ]
    },
    {
      "location": "ru-3",
      "location_code": "RU",
      "availability_zones": [
        "msk-1"
      ]
    },
    {
      "location": "pl-1",
      "location_code": "PL",
      "availability_zones": [
        "gdn-1"
      ]
    },
    {
      "location": "kz-1",
      "location_code": "KZ",
      "availability_zones": [
        "ala-1"
      ]
    },
    {
      "location": "ru-2",
      "location_code": "RU",
      "availability_zones": [
        "nsk-1"
      ]
    },
    {
      "location": "nl-1",
      "location_code": "NL",
      "availability_zones": [
        "ams-1"
      ]
    },
    {
      "location": "de-1",
      "location_code": "DE",
      "availability_zones": [
        "fra-1"
      ]
    }
  ],
  "meta": {
    "total": 7
  },
  "response_id": "95a2b61b-8fd8-4ed2-8a15-2784b1103970"
}
```

## Operating Systems

https://timeweb.cloud/api-docs#tag/Oblachnye-servery/operation/getOsList

```
{
  "servers_os": [
    {
      "id": 37,
      "family": "windows",
      "name": "windows",
      "version": "2012",
      "version_codename": "standard",
      "description": "",
      "requirements": {
        "disk_min": 35840
      }
    },
    {
      "id": 47,
      "family": "linux",
      "name": "ubuntu",
      "version": "18.04",
      "version_codename": "bionic",
      "description": ""
    },
    {
      "id": 50,
      "family": "windows",
      "name": "windows",
      "version": "2016",
      "version_codename": "datacenter",
      "description": "",
      "requirements": {
        "disk_min": 35840
      }
    },
    {
      "id": 51,
      "family": "windows",
      "name": "windows",
      "version": "2019",
      "version_codename": "datacenter",
      "description": "",
      "requirements": {
        "disk_min": 35840
      }
    },
    {
      "id": 61,
      "family": "linux",
      "name": "ubuntu",
      "version": "20.04",
      "version_codename": "focal",
      "description": ""
    },
    {
      "id": 67,
      "family": "linux",
      "name": "debian",
      "version": "11",
      "version_codename": "bullseye",
      "description": ""
    },
    {
      "id": 69,
      "family": "windows",
      "name": "windows",
      "version": "2022",
      "version_codename": "datacenter",
      "description": "",
      "requirements": {
        "disk_min": 35840
      }
    },
    {
      "id": 75,
      "family": "linux",
      "name": "almalinux",
      "version": "8.5",
      "version_codename": "Arctic Sphynx",
      "description": ""
    },
    {
      "id": 79,
      "family": "linux",
      "name": "ubuntu",
      "version": "22.04",
      "version_codename": "jammy",
      "description": ""
    },
    {
      "id": 81,
      "family": "linux",
      "name": "archlinux",
      "version": "1",
      "version_codename": "archlinux",
      "description": ""
    },
    {
      "id": 89,
      "family": "linux",
      "name": "astralinux",
      "version": "2.12",
      "version_codename": "orel",
      "description": ""
    },
    {
      "id": 91,
      "family": "linux",
      "name": "almalinux",
      "version": "9.0",
      "version_codename": "Emerald Puma",
      "description": ""
    },
    {
      "id": 95,
      "family": "linux",
      "name": "debian",
      "version": "12",
      "version_codename": "bookworm",
      "description": ""
    },
    {
      "id": 97,
      "family": "linux",
      "name": "centos",
      "version": "9",
      "version_codename": "stream",
      "description": ""
    },
    {
      "id": 99,
      "family": "linux",
      "name": "ubuntu",
      "version": "24.04",
      "version_codename": "noble",
      "description": ""
    },
    {
      "id": 107,
      "family": "linux",
      "name": "bitrix",
      "version": "9",
      "version_codename": "",
      "description": ""
    },
    {
      "id": 109,
      "family": "linux",
      "name": "debian",
      "version": "13",
      "version_codename": "trixie",
      "description": ""
    },
    {
      "id": 113,
      "family": "linux",
      "name": "centos",
      "version": "10",
      "version_codename": "stream",
      "description": ""
    },
    {
      "id": 115,
      "family": "linux",
      "name": "almalinux",
      "version": "10.0",
      "version_codename": "Purple Lion",
      "description": ""
    },
    {
      "id": 121,
      "family": "linux",
      "name": "fedora",
      "version": "43",
      "version_codename": "fedora",
      "description": ""
    },
    {
      "id": 123,
      "family": "linux",
      "name": "rocky",
      "version": "9",
      "version_codename": "rocky",
      "description": ""
    }
  ],
  "meta": {
    "total": 21
  },
  "response_id": "f5648c50-08de-4048-93f0-f877b48694cc"
}
```