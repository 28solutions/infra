locals {
  updown_recipients_section = [for s in data.onepassword_item.updown.section : s if s.label == "Recipients"][0]
  updown_recipients         = [for f in local.updown_recipients_section.field : "${f.label}:${nonsensitive(f.value)}"]

  updown_domains_section = [for s in data.onepassword_item.updown.section : s if s.label == "Domains"][0]
  updown_1p_domains      = { for f in local.updown_domains_section.field : f.label => nonsensitive(f.value) }
}

resource "updown_check" "checks" {
  for_each = local.updown_1p_domains

  url    = "https://${each.value}"
  period = 300

  recipients = local.updown_recipients
}
