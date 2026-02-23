terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.95"
    }
  }
}

variable "provider_settings" {
  type = object({
    yc_service_account_key_file = string
    yc_cloud_id                 = string
    yc_folder_id                = string
    yc_zone                     = string
    yc_network_name             = string
  })
  sensitive = true
}

variable "vm_options" {
  description = "Single VM options for Yandex VM."
  type = object({
    image_family         = string
    cores                = number
    memory               = number
    disk_gb              = number
    platform_id          = optional(string, "standard-v2")
    core_fraction        = optional(number)
    nat_ip_address       = optional(string)
    security_group_names = optional(list(string), [])
  })
}

variable "vm_name" {
  description = "VM hostname and resource name"
  type        = string
}

variable "cloud_config_content" {
  description = "Cloud-init config content"
  type        = string
  sensitive   = true
}

provider "yandex" {
  service_account_key_file = var.provider_settings.yc_service_account_key_file
  cloud_id                 = var.provider_settings.yc_cloud_id
  folder_id                = var.provider_settings.yc_folder_id
  zone                     = var.provider_settings.yc_zone
}

locals {
  security_group_names = var.vm_options.security_group_names
}

data "yandex_compute_image" "vm" {
  family = var.vm_options.image_family
}

data "yandex_vpc_network" "vm" {
  name      = var.provider_settings.yc_network_name
}

data "yandex_vpc_subnet" "network_subnets" {
  for_each  = toset(data.yandex_vpc_network.vm.subnet_ids)
  subnet_id = each.value
}

locals {
  subnet_ids_in_zone = [
    for s in data.yandex_vpc_subnet.network_subnets :
    s.id if s.zone == var.provider_settings.yc_zone
  ]
}

data "yandex_vpc_security_group" "vm" {
  for_each  = toset(local.security_group_names)
  name      = each.value
}

resource "yandex_compute_instance" "vm" {
  name        = var.vm_name
  hostname    = var.vm_name
  platform_id = var.vm_options.platform_id

  resources {
    cores         = var.vm_options.cores
    memory        = var.vm_options.memory
    core_fraction = var.vm_options.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm.id
      size     = var.vm_options.disk_gb
    }
  }

  network_interface {
    subnet_id      = one(local.subnet_ids_in_zone)
    nat            = true
    nat_ip_address = var.vm_options.nat_ip_address
    security_group_ids = length(local.security_group_names) > 0 ? [
      for sg_name in local.security_group_names : data.yandex_vpc_security_group.vm[sg_name].id
    ] : null
  }

  metadata = {
    user-data = var.cloud_config_content
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for sg_name in local.security_group_names :
        data.yandex_vpc_security_group.vm[sg_name].network_id == data.yandex_vpc_network.vm.id
      ])
      error_message = "All security groups from vm_options.security_group_names must belong to provider_settings.yc_network_name."
    }
  }
}

output "ip" {
  value = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}
