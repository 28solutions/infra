locals {
  clean_host    = replace(replace(var.hosts[0], "/^\\W+|\\W+$/", ""), "/\\W+/", "_")
  clean_methods = replace(join("_", var.methods), "/\\W+/", "")
  clean_path    = replace(replace(var.path, "/^\\W+|\\W+$/", ""), "/\\W+/", "_")

  traefik_router = "${local.clean_host}-${local.clean_methods}${local.clean_path != "" ? "-" : ""}${local.clean_path}"

  traefik_hosts_rule = join(" || ", formatlist("Host(`%s`)", var.hosts))
  traefik_path_rule  = var.path == "" ? "" : " && Path(`${var.path}`)"

  traefik_methods_rule = join(
    " || ",
    formatlist(
      "Method(`%s`)",
      contains(var.methods, "GET") && var.add_head ? setunion(var.methods, ["HEAD"]) : var.methods
    )
  )
}

resource "docker_image" "image" {
  name         = var.image
  keep_locally = true
}

resource "docker_container" "container" {
  name    = var.container
  image   = docker_image.image.image_id
  restart = "unless-stopped"

  ports {
    internal = var.internal_port
    ip       = var.listening_ip
  }

  network_mode = "bridge"

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
    value = "(${local.traefik_hosts_rule})${local.traefik_path_rule} && (${local.traefik_methods_rule})"
  }

  labels {
    label = "traefik.http.services.${var.container}.loadbalancer.server.port"
    value = var.internal_port
  }
}
