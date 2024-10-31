resource "docker_network" "socket" {
  name = "socket_docker"
}

resource "docker_image" "docker_proxy" {
  name         = "tecnativa/docker-socket-proxy:0.2"
  keep_locally = true
}

resource "docker_container" "docker_proxy" {
  name    = "docker_proxy"
  image   = docker_image.docker_proxy.image_id
  restart = "unless-stopped"
  env     = ["CONTAINERS=1"]

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.socket.name
  }
}

resource "docker_image" "reverse_proxy" {
  name         = "traefik:3.1.2"
  keep_locally = true
}

locals {
  certificates = data.terraform_remote_state.infra.outputs.certificates
}

resource "docker_container" "reverse_proxy" {
  name    = "reverse_proxy"
  image   = docker_image.reverse_proxy.image_id
  restart = "unless-stopped"
  user    = "200:300"

  upload {
    file = "/etc/traefik/dynamic/ssl.yaml"
    content = templatefile(
      "traefik/ssl.yaml",
      {
        common_names = sort(values(local.certificates)[*].common_name)
      }
    )
  }

  upload {
    file    = "/etc/traefik/dynamic/redirects.yaml"
    content = file("traefik/redirects.yaml")
  }

  upload {
    file = "/etc/traefik/dynamic/wkd.yaml"
    content = templatefile(
      "traefik/wkd.yaml",
      {
        pki_domain_name = data.terraform_remote_state.storage.outputs.pki_domain_name
      }
    )
  }

  command = [
    "--log.level=DEBUG",
    "--providers.file.directory=/etc/traefik/dynamic",
    "--providers.docker.endpoint=tcp://docker_proxy:2375",
    "--providers.docker.exposedbydefault=false",
    "--entrypoints.web.address=:80",
    "--entrypoints.web.http.redirections.entryPoint.to=websecure",
    "--entrypoints.web.http.redirections.entryPoint.scheme=https",
    "--entrypoints.websecure.address=:443",
    "--entrypoints.websecure.http.tls",
    "--entrypoints.api.address=:8080",
    "--api=true"
  ]

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

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.api.entrypoints"
    value = "api"
  }

  labels {
    label = "traefik.http.routers.api.rule"
    value = "PathPrefix(`/api`) || PathPrefix(`/dashboard`)"
  }

  labels {
    label = "traefik.http.routers.api.service"
    value = "api@internal"
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
    name = docker_network.tools.name
  }

  networks_advanced {
    name = docker_network.www.name
  }
}
