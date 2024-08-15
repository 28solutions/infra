resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "csr" {
  private_key_pem = tls_private_key.cert_private_key.private_key_pem
  dns_names       = var.dns_names

  subject {
    common_name         = var.common_name
    organization        = "Twenty Eight Solutions"
    organizational_unit = "IT"
    locality            = "Liege"
    province            = "Liege"
    country             = "BE"
  }
}

resource "acme_certificate" "certificate" {
  account_key_pem         = var.account_key_pem
  certificate_request_pem = tls_cert_request.csr.cert_request_pem

  dns_challenge {
    provider = "cloudflare"
  }
}
