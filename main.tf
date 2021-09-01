terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {
  zone            = "fr-par-1"
  region          = "fr-par"
}

resource "scaleway_instance_ip" "web_public_ip" {}

resource "scaleway_instance_server" "web" {
	type = "DEV1-S"
	image = "debian_bullseye"
	ip_id = scaleway_instance_ip.web_public_ip.id
}

output "instance_ip_addr" {
	value = scaleway_instance_server.web.public_ip
}
