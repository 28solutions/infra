resource "scaleway_tem_domain" "domain" {
  name       = data.cloudflare_zone.dns_zone.name
  accept_tos = true
}

resource "cloudflare_dns_record" "spf" {
  zone_id = data.cloudflare_zone.dns_zone.zone_id
  name    = "@"
  type    = "TXT"
  content = "\"v=spf1 include:_spf.google.com ${scaleway_tem_domain.domain.spf_config} ~all\""
}

resource "cloudflare_dns_record" "dkim" {
  zone_id = data.cloudflare_zone.dns_zone.zone_id
  name    = "${scaleway_tem_domain.domain.project_id}._domainkey"
  type    = "TXT"
  content = format("\"%s\"", join("\" \"", regexall(".{1,255}", scaleway_tem_domain.domain.dkim_config)))
}

resource "scaleway_tem_domain_validation" "validation" {
  domain_id = scaleway_tem_domain.domain.id
}

resource "scaleway_iam_application" "smtp" {
  for_each = toset(["Gitea", "Cartman"])

  name = each.key
}

resource "scaleway_iam_group" "smtp" {
  name = "SMTP"

  application_ids = [for app in scaleway_iam_application.smtp : app.id]
}

resource "scaleway_iam_policy" "smtp" {
  name = "SMTP"

  group_id = scaleway_iam_group.smtp.id
  rule {
    project_ids          = [scaleway_tem_domain.domain.project_id]
    permission_set_names = ["TransactionalEmailEmailFullAccess"]
  }
}

resource "scaleway_iam_api_key" "smtp" {
  for_each = scaleway_iam_application.smtp

  application_id = each.value.id
  description    = "SMTP | ${each.key}"
}

resource "onepassword_item" "smtp_login" {
  for_each = scaleway_iam_api_key.smtp

  vault = data.onepassword_vault.iac_vault.uuid

  title    = "Scaleway ${each.value.description}"
  category = "login"

  username = scaleway_tem_domain.domain.smtps_auth_user
  password = each.value.secret_key

  url = format(
    "smtp://%s:%d",
    scaleway_tem_domain.domain.smtp_host,
    scaleway_tem_domain.domain.smtps_port
  )
}
