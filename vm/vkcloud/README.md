# Module `vm/vkcloud`

Creates one `vkcs_compute_instance` with cloud-init and returns its public IPv4.

## Provider Setup

1. Open Account Security -> Setup two-factor auth, enable API access.
2. Open Project Settings -> Terraform -> Copy Project ID.
3. Use your account email and password as terraform provider settings.

## Quotas

- Virtual Machines
- Sprut External Network Ports - this is your public IP quota, increase it to your desired VM count

## Example

```hcl
module "vm_vkcloud" {
  source = "git::https://github.com/ad-ctf/terraform-providers.git//vm/vkcloud?ref=v1.1.0"

  provider_settings = {
    username   = var.vkcs_username
    password   = var.vkcs_password
    project_id = var.vkcs_project_id
  }

  vm_name = "ctf-vk-01"

  vm_options = {
    image_name        = "Ubuntu-22.04-2024.09"
    flavor_name       = "std3-2-4"
    os_distro         = "ubuntu"
    os_version        = "22.04"
    availability_zone = "MS1"
    disk_size         = 20
    disk_type         = "ceph-hdd"
  }

  cloud_config_content = file("${path.module}/cloud-init.yaml")
}
```

## Input Variables

`provider_settings` (`object`, sensitive):
- `username` (`string`) - username for credentials-based auth.
- `password` (`string`) - password for credentials-based auth.
- `project_id` (`string`, optional) - project ID.

`vm_name` (`string`):
- VM resource name and hostname.

`vm_options` (`object`):
- `flavor_name` (`string`) - flavor name "std\<category\>-\<vcpu\>-\<ram\>", open "Create VM" in UI to see available flavors.
- `os_distro` (`string`, optional, default: `"ubuntu"`) - OS distro for image lookup.
- `os_version` (`string`, optional, default: `"22.04"`) - OS version for image lookup.
- `availability_zone` (`string`, optional) - VM availability zone, see available zones [here](https://cloud.vk.com/docs/ru/start/concepts/architecture#az).
- `disk_size` (`number`, optional, default: `20`) - boot volume size in GB.
- `disk_type` (`string`, optional, default: `"ceph-hdd"`) - boot volume type, see available types [here](https://cloud.vk.com/docs/computing/iaas/concepts/data-storage/volume-sla).

`cloud_config_content` (`string`, sensitive):
- cloud-init content for `user_data`.

## Outputs

- `ip` - public IPv4 address (floating IP) assigned to the VM.
