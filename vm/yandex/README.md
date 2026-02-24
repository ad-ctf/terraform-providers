# Module `vm/yandex`

Creates one `yandex_compute_instance` in a selected zone and network.

## Provider Setup

1. Open dashboard, copy IDs at the top: cloud ID (left value) and folder ID (right value).
2. In the folder menu (near the folder ID), click "Create service account". Specify name of your choice and create account.
3. Click "Access Rights" button at the top of dashboard, then "Configure access".
4. Select your service account, add role `admin` and save.
5. In "All Services" menu (top-left button) open "Identity and Access Management".
6. Click on your service account.
7. Click top-right button "Create new key", select "Create authorized key".
8. Create a new key, click "Download file with keys" - this is your `yc_service_account_key_file`.

## Quotas

- Compute Cloud, number of instances - this is your VM count
- Virtual Private Cloud,  number of all public IP addresses - this also limits your VM count as each VM has own public IP

## Example

```hcl
module "vm_yc" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/yandex?ref=v1.0.0"

  provider_settings = {
    yc_service_account_key_file = "./yc_key.json"
    yc_cloud_id                 = var.yc_cloud_id
    yc_folder_id                = var.yc_folder_id
    yc_zone                     = "ru-central1-a"
    yc_network_name             = "default"
  }

  vm_name = "ctf-yc-01"

  vm_options = {
    image_family         = "ubuntu-2204-lts"
    cores                = 2
    memory               = 2
    disk_gb              = 20
    platform_id          = "standard-v2"
    core_fraction        = 20
    security_group_names = []
  }

  cloud_config_content = file("${path.module}/cloud-init.yaml")
}
```

## Input Variables

`provider_settings` (`object`, sensitive):
- `yc_service_account_key_file` (`string`) - path to service account JSON key file.
- `yc_cloud_id` (`string`) - cloud ID.
- `yc_folder_id` (`string`) - folder ID.
- `yc_zone` (`string`) - target VM zone. See list of zones here: https://yandex.cloud/en/docs/overview/concepts/region
- `yc_network_name` (`string`) - VPC network name used to select a subnet. Check "Virtual Private Cloud / Cloud networks" in UI, usually it is named `default`.

`vm_name` (`string`):
- VM resource name and hostname.

`vm_options` (`object`):
- `image_family` (`string`) - image family. Open "Compute Cloud / Virtual machines / Create" menu in UI, click info button for desired OS, copy `family_id` at the bottom. Remove `-oslogin` suffix if any, it will screw your cloud-init otherwise.
- `cores` (`number`) - number of vCPUs.
- `memory` (`number`) - RAM in GB.
- `disk_gb` (`number`) - boot disk size in GB.
- `platform_id` (`string`, optional, default: `"standard-v2"`). See list of platforms here: https://yandex.cloud/en/docs/compute/concepts/vm-platforms
- `core_fraction` (`number`, optional).
- `nat_ip_address` (`string`, optional) - static public IP if needed.
- `security_group_names` (`list(string)`, optional, default: `[]`) - security group names.

`cloud_config_content` (`string`, sensitive):
- cloud-init content.

## Outputs

- `ip` - public IPv4 address of the VM.

## Notes

- The module automatically picks a subnet from `yc_network_name` in `yc_zone`.
- NAT is always enabled (`nat = true`).
- A lifecycle precondition checks that all `security_group_names` belong to the same network as `yc_network_name`.
