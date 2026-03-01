terraform {
  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.14"
    }
  }
}

variable "provider_settings" {
  description = "VK Cloud provider settings."
  type = object({
    username   = string
    password   = string
    project_id = optional(string)
  })
  sensitive = true
}

variable "vm_options" {
  description = "VM options for VK Cloud."
  type = object({
    flavor_name       = string
    os_distro         = string
    os_version        = string
    availability_zone = optional(string)
    disk_size         = number
    disk_type         = optional(string, "ceph-hdd")
  })
}

variable "vm_name" {
  description = "VM hostname and resource name."
  type        = string
}

variable "cloud_config_content" {
  description = "Cloud-init config content."
  type        = string
  sensitive   = true
}

provider "vkcs" {
  username   = var.provider_settings.username
  password   = var.provider_settings.password
  project_id = var.provider_settings.project_id
}

data "vkcs_images_image" "image" {
  visibility = "public"
  default    = true
  properties = {
    mcs_os_distro  = var.vm_options.os_distro
    mcs_os_version = var.vm_options.os_version
  }
}

resource "vkcs_compute_instance" "vm" {
  name              = var.vm_name
  availability_zone = var.vm_options.availability_zone
  flavor_name       = var.vm_options.flavor_name
  user_data         = var.cloud_config_content

  block_device {
    source_type           = "image"
    uuid                  = data.vkcs_images_image.image.id
    destination_type      = "volume"
    volume_size           = var.vm_options.disk_size
    volume_type           = var.vm_options.disk_type
    delete_on_termination = true
  }

  network {
    name = "internet"
  }
}

output "ip" {
  value = vkcs_compute_instance.vm.access_ip_v4
}
