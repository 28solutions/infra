terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    bucket         = "28s-terraform"
    key            = "states/storage.tfstate"
    region         = "eu-central-1"
    profile        = "terraform"
    dynamodb_table = "TerraformStateLocks"
  }
}

provider "scaleway" {
  profile = "storage"
  zone    = "fr-par-1"
  region  = "fr-par"
}

provider "aws" {
  profile = "sdwbe"
  region  = "eu-central-1"
}
