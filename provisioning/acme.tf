variable "acme_email_address" {
  type        = string
  description = "ACME account email address"
}

variable "domain_name" {
  type        = string
  description = "Common name for TLS certificate"
  default     = "tools.28.solutions"
}

resource "tls_private_key" "acme_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "acme_registration" {
  account_key_pem = tls_private_key.acme_private_key.private_key_pem
  email_address   = var.acme_email_address
}

module "certificates" {
  source = "./acme-certificate"

  account_key_pem = tls_private_key.acme_private_key.private_key_pem
  common_name     = var.domain_name
  dns_names       = [var.domain_name]
}

output "domain_name" {
  value = module.certificates.common_name
}

output "certificate" {
  value     = module.certificates.certificate
  sensitive = true # not really sensitive, but it floods the console
}

output "certificate_private_key" {
  value     = module.certificates.private_key
  sensitive = true
}
