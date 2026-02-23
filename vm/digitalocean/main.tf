terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "provider_settings" {
  type = object({
    digitalocean_api_token = string
  })
}

variable "vm_options" {
  description = "Single VM options for DigitalOcean Droplet."
  type = object({
    image  = string
    region = string
    size   = string
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

provider "digitalocean" {
  token = var.provider_settings.digitalocean_api_token
}

resource "digitalocean_droplet" "vm" {
  image  = var.vm_options.image
  name   = var.vm_name
  region = var.vm_options.region
  size   = var.vm_options.size

  user_data = var.cloud_config_content
}

output "ip" {
  value = digitalocean_droplet.vm.ipv4_address
}
