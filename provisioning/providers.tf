terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.50.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.1.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.29.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.1.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }

  backend "s3" {
    key = "states/provisioning.tfstate"
  }
}

data "onepassword_item" "scaleway_web" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Scaleway - web"
}

locals {
  op_project_section = [for s in data.onepassword_item.scaleway_web.section : s if s.label == "Project"][0]
  op_project_fields  = { for f in local.op_project_section.field : f.label => f.value }
}

provider "scaleway" {
  access_key = data.onepassword_item.scaleway_web.username
  secret_key = data.onepassword_item.scaleway_web.credential

  organization_id = local.op_project_fields["Organization ID"]
  project_id      = local.op_project_fields["Project ID"]

  region = "fr-par"
  zone   = "fr-par-1"
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
