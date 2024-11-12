locals {
  websites = {
    pki = {
      provider   = "aws"
      bucket     = "sdw-pki"
      versioning = true
      title      = "PKI"
      icon       = "key"
      owner      = "Stéphane de Wit"
    }
    downloads_sdw = {
      provider   = "scw"
      bucket     = "sdw-downloads"
      versioning = false
      title      = "Downloads"
      icon       = "download"
      owner      = "Stéphane de Wit"
    }
    downloads_28s = {
      provider   = "scw"
      bucket     = "28s-downloads"
      versioning = false
      title      = "Downloads"
      icon       = "download"
      owner      = "Twenty Eight Solutions"
    }
  }
}

module "website" {
  for_each = local.websites

  source = "./static-website"

  cloud_provider = each.value.provider

  bucket            = each.value.bucket
  bucket_versioning = each.value.versioning

  title = each.value.title
  icon  = each.value.icon
  owner = each.value.owner
}

output "pki_domain_name" {
  value = module.website["pki"].domain_name
}

output "downloads_sdw_domain_name" {
  value = module.website["downloads_sdw"].domain_name
}

output "downloads_28s_domain_name" {
  value = module.website["downloads_28s"].domain_name
}
