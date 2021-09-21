terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    acme = {
      source = "vancluever/acme"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    bucket         = "28s-terraform"
    key            = "states/infra.tfstate"
    region         = "eu-central-1"
    profile        = "terraform"
    dynamodb_table = "TerraformStateLocks"
  }
}

provider "scaleway" {
  zone   = "fr-par-1"
  region = "fr-par"
}

variable "acme_production" {
  type        = bool
  description = "Use production ACME endpoint"
}

locals {
  acme_production_endpoint = "https://acme-v02.api.letsencrypt.org/directory"
  acme_staging_endpoint    = "https://acme-staging-v02.api.letsencrypt.org/directory"

  acme_directory = var.acme_production ? local.acme_production_endpoint : local.acme_staging_endpoint
}

provider "acme" {
  server_url = local.acme_directory
}

output "acme_directory" {
  value = local.acme_directory
}
