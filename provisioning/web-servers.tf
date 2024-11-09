variable "ssh_port" {
  type        = number
  description = "SSH listening port"
  default     = 44265
}

data "onepassword_item" "ssh_key" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Scaleway SSH key"
}

resource "scaleway_account_ssh_key" "main" {
  public_key = data.onepassword_item.ssh_key.public_key
}

resource "scaleway_instance_security_group" "www" {
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action = "accept"
    port   = var.ssh_port
  }

  inbound_rule {
    action = "accept"
    port   = 80
  }

  inbound_rule {
    action = "accept"
    port   = 443
  }
}

resource "scaleway_instance_ip" "web_public_ip" {}

resource "scaleway_instance_server" "web" {
  type              = "DEV1-S"
  image             = "debian_bookworm"
  ip_id             = scaleway_instance_ip.web_public_ip.id
  security_group_id = scaleway_instance_security_group.www.id

  user_data = {
    cloud-init = templatefile("${path.module}/cloud-init.yaml", { port = var.ssh_port })
  }

  provisioner "remote-exec" {
    inline = ["uname -a"]

    connection {
      type        = "ssh"
      host        = self.public_ips[0].address
      port        = var.ssh_port
      user        = "root"
      private_key = data.onepassword_item.ssh_key.private_key
    }
  }
}

data "cloudflare_zone" "dns_zone" {
  name = "28.solutions"
}

resource "cloudflare_record" "kenny_dns" {
  zone_id = data.cloudflare_zone.dns_zone.id
  name    = "kenny.hosts"
  type    = "A"
  content = scaleway_instance_server.web.public_ips[0].address
}

output "web_server_ip_address" {
  value = scaleway_instance_server.web.public_ips[0].address
}

output "web_server_hostname" {
  value = cloudflare_record.kenny_dns.hostname
}

output "web_server_ssh_port" {
  value = var.ssh_port
}
