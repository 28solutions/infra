resource "docker_network" "socket" {
  name = "docker-socket"
}

resource "docker_image" "docker_proxy" {
  name         = "tecnativa/docker-socket-proxy:0.3"
  keep_locally = true
}

resource "docker_container" "docker_proxy" {
  name    = "docker-proxy"
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
