terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    acme = {
      source = "vancluever/acme"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
  }

  backend "s3" {
    key = "states/provisioning.tfstate"
  }
}

provider "scaleway" {
  profile = "web"
  zone    = "fr-par-1"
  region  = "fr-par"
}

data "onepassword_item" "cloudflare_zone_read" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Cloudflare | Zone:Read"
}

data "onepassword_item" "cloudflare_dns_edit" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Cloudflare | DNS:Edit"
}

provider "cloudflare" {
  api_token = data.onepassword_item.cloudflare_dns_edit.credential
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
