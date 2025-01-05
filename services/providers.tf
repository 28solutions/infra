terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.5"
    }
  }

  backend "s3" {
    key = "states/services.tfstate"
  }
}

data "onepassword_item" "docker_host" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Docker SSL server certificate - Kenny"
}

data "http" "ca_certificate" {
  url = "https://${data.terraform_remote_state.storage.outputs.pki_domain_name}/ssl/ca/certificate.pem"

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Invalid status code"
    }
  }
}

data "onepassword_item" "ssl_certificate" {
  vault = data.onepassword_vault.iac_vault.uuid
  title = "Docker SSL client certificate - Terraform"
}

locals {
  docker_host = data.terraform_remote_state.provisioning.outputs.web_server_hostname
  docker_port = [for field in data.onepassword_item.docker_host.section[0].field : field.value if field.label == "port"][0]

  docker_cert = [for file in data.onepassword_item.ssl_certificate.section[0].file : file.content if file.name == "certificate.pem"][0]
  docker_key  = [for file in data.onepassword_item.ssl_certificate.section[0].file : file.content if file.name == "private-key.pem"][0]
}

provider "docker" {
  host = "tcp://${local.docker_host}:${local.docker_port}"

  ca_material   = data.http.ca_certificate.response_body
  cert_material = local.docker_cert
  key_material  = local.docker_key
}
