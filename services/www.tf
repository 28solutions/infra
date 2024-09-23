resource "docker_network" "www" {
  name = "www"
}

module "www_28s_service" {
  source = "./docker-http-service"

  image         = "28solutions/www:0.2.0"
  container     = "www_28s"
  internal_port = 8080
  network       = docker_network.www.name

  hosts = [
    "twentyeight.solutions",
    "28.solutions"
  ]
  methods = ["GET"]
}

module "www_sdw_service" {
  source = "./docker-http-service"

  image         = "stephdewit/www:0.1.1"
  container     = "www_sdw"
  internal_port = 8080
  network       = docker_network.www.name

  hosts = [
    "www.stephanedewit.be"
  ]
  methods = ["GET"]
}
