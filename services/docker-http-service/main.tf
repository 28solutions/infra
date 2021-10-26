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
}
