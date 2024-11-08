locals {
  websites = {
    pki = {
      provider   = "aws"
      bucket     = "sdw-pki"
      versioning = true
      title      = "PKI"
      icon       = "key"
    }
    downloads_sdw = {
      provider   = "scw"
      bucket     = "sdw-downloads"
      versioning = false
      title      = "Downloads"
      icon       = "download"
    }
    downloads_28s = {
      provider   = "scw"
      bucket     = "28s-downloads"
      versioning = false
      title      = "Downloads"
      icon       = "download"
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
