data "onepassword_item" "ssh_key" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Scaleway SSH key"
}

resource "scaleway_account_ssh_key" "main" {
  name       = "Terraform"
  public_key = data.onepassword_item.ssh_key.public_key
}

data "onepassword_item" "docker_host" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Docker SSL server certificate - Kenny"
}

data "onepassword_item" "ssh" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "SSH - Kenny"
}

locals {
  docker_port = tonumber([for field in data.onepassword_item.docker_host.section[0].field : field.value if field.label == "port"][0])
  ssh_port    = tonumber([for field in data.onepassword_item.ssh.section[0].field : field.value if field.label == "port"][0])
}

resource "scaleway_instance_security_group" "www" {
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action = "accept"
    port   = local.ssh_port
  }

  inbound_rule {
    action = "accept"
    port   = local.docker_port
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
    cloud-init = templatefile("${path.module}/cloud-init.yaml", { port = local.ssh_port })
  }

  provisioner "remote-exec" {
    inline = ["uname -a"]

    connection {
      type        = "ssh"
      host        = self.public_ips[0].address
      port        = local.ssh_port
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
  value     = local.ssh_port
  sensitive = true
}
