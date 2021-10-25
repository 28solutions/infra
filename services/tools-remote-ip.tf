resource "docker_network" "tools" {
  name = "tools"
}

resource "docker_image" "tools_remote_ip" {
  name         = "28solutions/tools-remote-ip:0.1.2"
  keep_locally = true
}

resource "docker_container" "tools_remote_ip" {
  name  = "tools_remote_ip"
  image = docker_image.tools_remote_ip.latest

  ports {
    internal = 8000
  }

  networks_advanced {
    name = docker_network.tools.name
  }
}
