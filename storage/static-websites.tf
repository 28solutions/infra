module "pki_website" {
  source = "./static-website"

  cloud_provider = "aws"

  bucket            = "sdw-pki"
  bucket_versioning = true

  title = "PKI"
  icon  = "key"
}

output "pki_domain_name" {
  value = module.pki_website.domain_name
}

module "downloads_sdw_website" {
  source = "./static-website"

  cloud_provider = "scw"

  bucket = "sdw-downloads"

  title = "Downloads"
  icon  = "download"
}

output "downloads_sdw_domain_name" {
  value = module.downloads_sdw_website.domain_name
}

module "downloads_28s_website" {
  source = "./static-website"

  cloud_provider = "scw"

  bucket = "28s-downloads"

  title = "Downloads"
  icon  = "download"
}

output "downloads_28s_domain_name" {
  value = module.downloads_28s_website.domain_name
}
