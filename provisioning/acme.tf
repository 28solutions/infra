variable "acme_email_address" {
  type        = string
  description = "ACME account email address"
}

variable "acme_domain_names" {
  type        = map(list(string))
  description = "Common name for TLS certificate"
}

resource "tls_private_key" "acme_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "acme_registration" {
  account_key_pem = tls_private_key.acme_private_key.private_key_pem
  email_address   = var.acme_email_address
}

data "onepassword_item" "cloudflare_zone_read" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Cloudflare | Zone:Read"
}

module "certificates" {
  for_each = var.acme_domain_names

  source = "./acme-certificate"

  account_key_pem = tls_private_key.acme_private_key.private_key_pem
  common_name     = each.value[0]
  dns_names       = each.value

  cloudflare_tokens = {
    zone_read = data.onepassword_item.cloudflare_zone_read.credential
    dns_edit  = data.onepassword_item.cloudflare_dns_edit.credential
  }
}

output "certificates" {
  value     = module.certificates
  sensitive = true
}
