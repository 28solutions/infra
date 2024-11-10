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

provider "scaleway" {
  profile = "storage"
  zone    = "fr-par-1"
  region  = "fr-par"
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
