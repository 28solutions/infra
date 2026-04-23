terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.42.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
  }
}

data "onepassword_item" "aws_28s" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Amazon Web Services - 28s terraform"
}

provider "aws" {
  access_key = data.onepassword_item.aws_28s.username
  secret_key = data.onepassword_item.aws_28s.credential
  region     = var.region
}
