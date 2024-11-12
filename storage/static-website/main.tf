module "aws_website" {
  source = "./aws"

  count = var.cloud_provider == "aws" ? 1 : 0

  bucket            = var.bucket
  bucket_versioning = var.bucket_versioning

  title = var.title
  icon  = var.icon
  owner = var.owner
}

module "scaleway_website" {
  source = "./scw"

  count = var.cloud_provider == "scw" ? 1 : 0

  bucket            = var.bucket
  bucket_versioning = var.bucket_versioning

  title = var.title
  icon  = var.icon
  owner = var.owner
}

output "domain_name" {
  value = flatten(concat(
    module.aws_website[*].domain_name,
    module.scaleway_website[*].domain_name
  ))[0]
}
