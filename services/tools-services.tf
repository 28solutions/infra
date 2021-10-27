locals {
  host = "tools.28.solutions"
}

resource "docker_network" "tools" {
  name = "tools"
}

module "remote_ip_service" {
  source = "./docker-http-service"

  image     = "28solutions/tools-remote-ip:0.1.2"
  container = "tools_remote_ip"
  network   = docker_network.tools.name

  host    = local.host
  methods = ["GET"]
  path    = "/ip"
}

module "hash_service" {
  source = "./docker-http-service"

  image     = "28solutions/tools-hash:0.1.3"
  container = "tools_hash"
  network   = docker_network.tools.name

  host    = local.host
  methods = ["POST", "PUT"]
  path    = "/hash"
}

module "ui_service" {
  source = "./docker-http-service"

  image         = "28solutions/tools-ui:0.0.2"
  container     = "tools_ui"
  internal_port = 8080
  network       = docker_network.tools.name

  host    = local.host
  methods = ["GET"]
}
