resource "docker_image" "tools_hash" {
  name         = "28solutions/tools-hash:0.1.3"
  keep_locally = true
}

resource "docker_container" "tools_hash" {
  name  = "tools_hash"
  image = docker_image.tools_hash.latest

  ports {
    internal = 8000
  }

  networks_advanced {
    name = docker_network.tools.name
  }
}
