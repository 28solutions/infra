terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
  }

  backend "s3" {
    key = "states/services.tfstate"
  }
}

locals {
  ssh_host = data.terraform_remote_state.provisioning.outputs.web_server_hostname
  ssh_port = data.terraform_remote_state.provisioning.outputs.web_server_ssh_port

  ssh_cert_file = "/ssh/terraform-cert.pub"
  ssh_cert_opt  = fileexists(local.ssh_cert_file) ? ["-o", "CertificateFile=${local.ssh_cert_file}"] : []
}

provider "docker" {
  host     = "ssh://stephdewit@${local.ssh_host}:${local.ssh_port}"
  ssh_opts = concat(["-o", "ControlMaster=no"], local.ssh_cert_opt)
}
