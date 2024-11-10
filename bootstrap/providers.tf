terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    onepassword = {
      source = "1Password/onepassword"
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
