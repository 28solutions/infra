resource "docker_network" "www" {
  name = "www"
}

module "www_service" {
  source = "./docker-http-service"

  image         = "28solutions/www:0.1.0"
  container     = "www_28s"
  internal_port = 80
  network       = docker_network.www.name

  hosts = [
    "twentyeight.solutions",
    "28.solutions"
  ]
  methods = ["GET"]
}
