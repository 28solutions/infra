locals {
  domain_names = flatten(values(var.acme_domain_names))
  apex         = toset([for n in local.domain_names : regex("[^.]+[.][^.]+$", n)])
  auto_ttl     = 1
}

data "cloudflare_zone" "zones" {
  for_each = local.apex

  name = each.key
}

resource "cloudflare_record" "caa_issue" {
  for_each = data.cloudflare_zone.zones

  zone_id = each.value.id
  name    = "@"
  ttl     = local.auto_ttl
  type    = "CAA"

  data {
    flags = 0
    tag   = "issue"
    value = "letsencrypt.org"
  }
}
