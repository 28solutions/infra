locals {
  traefik_router = "${replace(var.host, ".", "-")}_${replace(var.path, "/", "")}"
}

resource "docker_image" "image" {
  name         = var.image
  keep_locally = true
}

resource "docker_container" "container" {
  name  = var.container
  image = docker_image.image.latest

  ports {
    internal = var.internal_port
    ip       = var.listening_ip
  }

  networks_advanced {
    name = var.network
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.${local.traefik_router}.entrypoints"
    value = "web"
  }

  labels {
    label = "traefik.http.routers.${local.traefik_router}.rule"
    value = "Host(`${var.host}`) && Path(`${var.path}`)"
  }
}
