variable "ssh_private_key" {
  type        = string
  description = "A matching .pub file must exist"
}

resource "scaleway_account_ssh_key" "main" {
  public_key = file("${var.ssh_private_key}.pub")
}

resource "scaleway_instance_security_group" "www" {
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action = "accept"
    port   = 22
  }
}

resource "scaleway_instance_ip" "web_public_ip" {}

resource "scaleway_instance_server" "web" {
  type              = "DEV1-S"
  image             = "debian_bullseye"
  ip_id             = scaleway_instance_ip.web_public_ip.id
  security_group_id = scaleway_instance_security_group.www.id

  provisioner "remote-exec" {
    inline = ["uname -a"]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "root"
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i ${self.public_ip}, --private-key '${var.ssh_private_key}' ../deployment/playbook.yaml"
  }
}

output "web_server_ip_address" {
  value = scaleway_instance_server.web.public_ip
}
