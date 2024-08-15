locals {
  clean_host    = replace(replace(var.host, "/^\\W+|\\W+$/", ""), "/\\W+/", "_")
  clean_methods = replace(join("_", var.methods), "/\\W+/", "")
  clean_path    = replace(replace(var.path, "/^\\W+|\\W+$/", ""), "/\\W+/", "_")

  traefik_router  = "${local.clean_host}-${local.clean_methods}${local.clean_path != "" ? "-" : ""}${local.clean_path}"

  traefik_methods_rule = join(" || ", formatlist("Method(`%s`)", var.methods))
  traefik_path_rule    = var.path == "" ? "" : " && Path(`${var.path}`)"
}

resource "docker_image" "image" {
  name         = var.image
  keep_locally = true
}

resource "docker_container" "container" {
  name  = var.container
  image = docker_image.image.repo_digest

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
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.${local.traefik_router}.rule"
    value = "Host(`${var.host}`)${local.traefik_path_rule} && (${local.traefik_methods_rule})"
  }

  labels {
    label = "traefik.http.services.${var.container}.loadbalancer.server.port"
    value = var.internal_port
  }
}
