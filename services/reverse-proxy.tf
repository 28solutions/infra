resource "docker_image" "reverse_proxy" {
  name         = "traefik:3.2.1"
  keep_locally = true
}

locals {
  certificates = values(data.terraform_remote_state.provisioning.outputs.certificates)

  sorted_common_names = sort(local.certificates[*].common_name)
  sorted_certificates = flatten(
    [for common_name in local.sorted_common_names :
      [for certificate in local.certificates :
        certificate if common_name == certificate.common_name
      ]
    ]
  )
}

resource "onepassword_item" "api_account" {
  vault = data.onepassword_vault.iac_vault.uuid

  title    = "Traefik dashboard"
  category = "login"

  username = "stephdewit"

  password_recipe {
    length  = 64
    symbols = false
  }

  url = "https://${data.terraform_remote_state.provisioning.outputs.certificates["traefik"].common_name}"
}

locals {
  api_realm = "traefik"
  api_users = [
    {
      username = onepassword_item.api_account.username
      password = onepassword_item.api_account.password
    }
  ]
}

variable "enabled_telemetry" {
  type = object({
    metrics = bool
    traces  = bool
  })

  default = {
    metrics = false
    traces  = true
  }
}

resource "docker_container" "reverse_proxy" {
  name    = "reverse-proxy"
  image   = docker_image.reverse_proxy.image_id
  restart = "unless-stopped"
  user    = "200:300"

  upload {
    file = "/etc/traefik/traefik.yaml"
    content = templatefile(
      "traefik/static.yaml",
      {
        docker_proxy_endpoint = "${docker_container.docker_proxy.name}:2375"
        otel_collector_grpc   = "${docker_container.otel_collector.name}:4317"
        enabled_telemetry     = var.enabled_telemetry
      }
    )
  }

  upload {
    file = "/etc/traefik/dynamic/ssl.yaml"
    content = templatefile(
      "traefik/ssl.yaml",
      {
        certificates = local.sorted_certificates
      }
    )
  }

  upload {
    file = "/etc/traefik/dynamic/api.yaml"
    content = templatefile(
      "traefik/api.yaml",
      {
        realm = local.api_realm
        users = [for user in local.api_users : {
          username        = user.username
          hashed_password = md5("${user.username}:${local.api_realm}:${user.password}")
        }]
      }
    )
  }

  upload {
    file    = "/etc/traefik/dynamic/redirects.yaml"
    content = file("traefik/redirects.yaml")
  }

  upload {
    file = "/etc/traefik/dynamic/downloads.yaml"
    content = templatefile(
      "traefik/downloads.yaml",
      {
        websites = {
          sdw = {
            tld    = "stephanedewit.be"
            target = data.terraform_remote_state.storage.outputs.downloads_sdw_domain_name
          }
          "28s" = {
            tld    = "twentyeight.solutions"
            target = data.terraform_remote_state.storage.outputs.downloads_28s_domain_name
          }
        }
      }
    )
  }

  upload {
    file = "/etc/traefik/dynamic/pki.yaml"
    content = templatefile(
      "traefik/pki.yaml",
      {
        pki_domain_name = data.terraform_remote_state.storage.outputs.pki_domain_name
      }
    )
  }

  upload {
    file    = "/etc/traefik/dynamic/wkd.yaml"
    content = file("traefik/wkd.yaml")
  }

  volumes {
    host_path      = "/etc/ssl/local-certs"
    container_path = "/etc/ssl/local-certs"
    read_only      = true
  }

  volumes {
    host_path      = "/etc/ssl/private"
    container_path = "/etc/ssl/private"
    read_only      = true
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  ports {
    internal = 8080
    ip       = "127.0.0.1"
    external = 8080
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.socket.name
  }

  networks_advanced {
    name = docker_network.otel.name
  }

  networks_advanced {
    name = docker_network.tools.name
  }

  networks_advanced {
    name = docker_network.www.name
  }
}
