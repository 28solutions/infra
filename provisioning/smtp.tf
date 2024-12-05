resource "scaleway_tem_domain" "domain" {
  name       = data.cloudflare_zone.dns_zone.name
  accept_tos = true
}

resource "cloudflare_record" "spf" {
  zone_id = data.cloudflare_zone.dns_zone.id
  name    = "@"
  type    = "TXT"
  content = "\"v=spf1 include:_spf.google.com ${scaleway_tem_domain.domain.spf_config} ~all\""
}

resource "cloudflare_record" "dkim" {
  zone_id = data.cloudflare_zone.dns_zone.id
  name    = "${scaleway_tem_domain.domain.project_id}._domainkey"
  type    = "TXT"
  content = format("\"%s\"", join("\" \"", regexall(".{1,255}", scaleway_tem_domain.domain.dkim_config)))
}

resource "scaleway_tem_domain_validation" "validation" {
  domain_id = scaleway_tem_domain.domain.id
}
