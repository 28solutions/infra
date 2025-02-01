resource "tls_private_key" "cert_private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

locals {
  with_www = compact(flatten(
    [for d in var.dns_names : [d, startswith(d, "*.") ? null : "www.${d}"]]
  ))

  wildcards = [
    for d in local.with_www : trimprefix(d, "*") if startswith(d, "*.")
  ]

  dns_names = distinct(length(local.wildcards) == 0
    ? local.with_www
    : flatten(
      [for d in local.with_www :
        [for w in local.wildcards : d if !endswith(d, w) || d == "*${w}"]
      ]
    )
  )
}

resource "tls_cert_request" "csr" {
  private_key_pem = tls_private_key.cert_private_key.private_key_pem
  dns_names       = local.dns_names

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

    config = {
      CF_ZONE_API_TOKEN = var.cloudflare_tokens.zone_read
      CF_DNS_API_TOKEN  = var.cloudflare_tokens.dns_edit
    }
  }
}
