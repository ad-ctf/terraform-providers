terraform {
  required_providers {
    twc = {
      source  = "tf.timeweb.cloud/timeweb-cloud/timeweb-cloud"
      version = "~> 1.6"
    }
  }
}

variable "provider_settings" {
  type = object({
    twc_token = string
  })
  sensitive = true
}

variable "vm_options" {
  description = "Single VM options for Timeweb: location, preset_type, os_name, os_version, availability_zone, disk_gb, cpu, ram_mb."
  type = object({
    location          = string
    preset_type       = string
    os_name           = string
    os_version        = string
    availability_zone = string
    disk_gb           = number
    cpu               = number
    ram_mb            = number
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

provider "twc" {
  token = var.provider_settings.twc_token
}

data "twc_configurator" "vm" {
  location    = var.vm_options.location
  preset_type = var.vm_options.preset_type
}

data "twc_os" "vm" {
  name    = var.vm_options.os_name
  version = var.vm_options.os_version
}

resource "twc_floating_ip" "vm_ip" {
  availability_zone = var.vm_options.availability_zone
  comment           = "${var.vm_name} IP"
}

resource "twc_server" "vm" {
  name              = var.vm_name
  hostname          = var.vm_name
  os_id             = data.twc_os.vm.id
  cloud_init        = var.cloud_config_content
  availability_zone = var.vm_options.availability_zone
  floating_ip_id    = twc_floating_ip.vm_ip.id

  configuration {
    configurator_id = data.twc_configurator.vm.id
    disk            = 1024 * var.vm_options.disk_gb
    cpu             = var.vm_options.cpu
    ram             = var.vm_options.ram_mb
  }
}

output "ip" {
  value = twc_server.vm.main_ipv4
}
