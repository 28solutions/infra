terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }

  backend "s3" {
    bucket         = "28s-terraform"
    key            = "states/services.tfstate"
    region         = "eu-central-1"
    profile        = "terraform"
    dynamodb_table = "TerraformStateLocks"
  }
}

provider "docker" {
  host     = "ssh://stephdewit@kenny.hosts.28.solutions:44265"
  ssh_opts = ["-o", "ControlMaster=no"]
}
