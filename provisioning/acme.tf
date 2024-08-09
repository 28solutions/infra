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

resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "csr" {
  private_key_pem = tls_private_key.cert_private_key.private_key_pem
  dns_names       = [var.domain_name]

  subject {
    common_name         = var.domain_name
    organization        = "Twenty Eight Solutions"
    organizational_unit = "IT"
    locality            = "Liege"
    province            = "Liege"
    country             = "BE"
  }
}

resource "acme_certificate" "certificate" {
  account_key_pem         = acme_registration.acme_registration.account_key_pem
  certificate_request_pem = tls_cert_request.csr.cert_request_pem

  dns_challenge {
    provider = "cloudflare"
  }
}

output "domain_name" {
  value = var.domain_name
}

output "certificate" {
  value     = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
  sensitive = true # not really sensitive, but it floods the console
}

output "certificate_private_key" {
  value     = tls_private_key.cert_private_key.private_key_pem
  sensitive = true
}
