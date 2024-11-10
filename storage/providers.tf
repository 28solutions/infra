terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    aws = {
      source = "hashicorp/aws"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
  }

  backend "s3" {
    key = "states/storage.tfstate"
  }
}

data "onepassword_item" "scaleway_storage" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Scaleway - storage"
}

locals {
  op_project_section = [for s in data.onepassword_item.scaleway_storage.section : s if s.label == "Project"][0]
  op_project_fields  = { for f in local.op_project_section.field : f.label => f.value }
}

provider "scaleway" {
  access_key = data.onepassword_item.scaleway_storage.username
  secret_key = data.onepassword_item.scaleway_storage.credential

  organization_id = local.op_project_fields["Organization ID"]
  project_id      = local.op_project_fields["Project ID"]

  region = "fr-par"
  zone   = "fr-par-1"
}

data "onepassword_item" "aws_sdw" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Amazon Web Services - SDW terraform"
}

provider "aws" {
  access_key = data.onepassword_item.aws_sdw.username
  secret_key = data.onepassword_item.aws_sdw.credential
  region     = "eu-central-1"
}
