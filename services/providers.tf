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

locals {
  ssh_host = data.terraform_remote_state.provisioning.outputs.web_server_hostname
  ssh_port = data.terraform_remote_state.provisioning.outputs.web_server_ssh_port
}

provider "docker" {
  host     = "ssh://stephdewit@${local.ssh_host}:${local.ssh_port}"
  ssh_opts = ["-o", "ControlMaster=no"]
}
