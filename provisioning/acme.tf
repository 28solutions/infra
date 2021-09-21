resource "tls_private_key" "acme_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "acme_registration" {
  account_key_pem = tls_private_key.acme_private_key.private_key_pem
  email_address   = "stephane@twentyeight.solutions"
}

output "acme_email_address" {
  value = acme_registration.acme_registration.email_address
}

output "acme_private_key" {
  value     = tls_private_key.acme_private_key.private_key_pem
  sensitive = true
}
