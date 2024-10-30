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

module "certificates" {
  for_each = var.acme_domain_names

  source = "./acme-certificate"

  account_key_pem = tls_private_key.acme_private_key.private_key_pem
  common_name     = each.value[0]
  dns_names       = each.value
}

output "certificates" {
  value     = module.certificates
  sensitive = true
}
