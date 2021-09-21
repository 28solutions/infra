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

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
