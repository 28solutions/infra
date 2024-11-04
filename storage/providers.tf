terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    aws = {
      source = "hashicorp/aws"
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

provider "aws" {
  profile = "sdwbe"
  region  = "eu-central-1"
}
