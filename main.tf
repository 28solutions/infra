terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

variable "ssh_private_key" {
	type = string
	description = "A matching .pub file must exist"
}

provider "scaleway" {
  zone            = "fr-par-1"
  region          = "fr-par"
}

resource "scaleway_account_ssh_key" "main"{
	public_key = file("${var.ssh_private_key}.pub")
}

resource "scaleway_instance_security_group" "www" {
	inbound_default_policy = "drop"
	outbound_default_policy = "accept"

	inbound_rule {
		action = "accept"
		port = 22
	}
}

resource "scaleway_instance_ip" "web_public_ip" {}

resource "scaleway_instance_server" "web" {
	type = "DEV1-S"
	image = "debian_bullseye"
	ip_id = scaleway_instance_ip.web_public_ip.id
	security_group_id = scaleway_instance_security_group.www.id
}

output "instance_ip_addr" {
	value = scaleway_instance_server.web.public_ip
}
