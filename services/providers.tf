terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }

  backend "s3" {
    key = "states/services.tfstate"
  }
}

provider "docker" {
  host     = "ssh://stephdewit@kenny.hosts.28.solutions:44265"
  ssh_opts = ["-o", "ControlMaster=no"]
}

data "terraform_remote_state" "storage" {
  backend = "s3"

  config = {
    bucket         = var.bucket
    key            = "states/storage.tfstate"
    region         = var.region
    profile        = var.profile
    dynamodb_table = var.dynamodb_table
  }
}
