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

module "downloads_website" {
  source = "./static-website"

  cloud_provider = "scw"

  bucket = "sdw-downloads"

  title = "Downloads"
  icon  = "download"
}

output "downloads_domain_name" {
  value = module.downloads_website.domain_name
}