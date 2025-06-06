locals {
  domain_names = flatten(values(var.acme_domain_names))
  apex         = toset([for n in local.domain_names : regex("[^.]+[.][^.]+$", n)])
}

data "cloudflare_zones" "zones_search" {
  for_each = local.apex

  name = each.key
}

data "cloudflare_zone" "zones" {
  for_each = data.cloudflare_zones.zones_search

  zone_id = each.value.result[0].id
}

resource "cloudflare_dns_record" "caa_issue" {
  for_each = data.cloudflare_zone.zones

  zone_id = each.value.zone_id
  name    = each.value.name
  ttl     = local.dns_records_auto_ttl
  type    = "CAA"

  data = {
    flags = 0
    tag   = "issue"
    value = "letsencrypt.org"
  }
}
