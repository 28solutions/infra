resource "docker_network" "socket" {
  name = "socket_docker"
}

resource "docker_image" "docker_proxy" {
  name         = "tecnativa/docker-socket-proxy:0.2"
  keep_locally = true
}

resource "docker_container" "docker_proxy" {
  name  = "docker_proxy"
  image = docker_image.docker_proxy.repo_digest
  env   = ["CONTAINERS=1"]

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  networks_advanced {
    name = docker_network.socket.name
  }
}

resource "docker_image" "reverse_proxy" {
  name         = "traefik:2.5.3"
  keep_locally = true
}

resource "docker_container" "reverse_proxy" {
  name  = "reverse_proxy"
  image = docker_image.reverse_proxy.repo_digest
  user  = "1000:1000"

  command = [
    "--providers.docker.endpoint=tcp://docker_proxy:2375",
    "--providers.docker.exposedbydefault=false",
    "--entrypoints.web.address=:8080"
  ]

  ports {
    internal = 8080
    external = 80
  }

  networks_advanced {
    name = docker_network.socket.name
  }

  networks_advanced {
    name = docker_network.tools.name
  }
}
