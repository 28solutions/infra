output "common_name" {
  value = var.common_name
}

output "certificate" {
  value = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
}

output "private_key" {
  value     = tls_private_key.cert_private_key.private_key_pem
  sensitive = true
}
