locals {
  wordle_solver_host = "wordle-solver.stephdew.it"
}

module "wordle_solver_api" {
  source = "./docker-http-service"

  image         = "stephdewit/wordle-solver:0.4.0"
  container     = "wordle-solver-api"
  internal_port = 8080
  network       = docker_network.www.name

  hosts   = [local.wordle_solver_host]
  methods = ["POST"]
  path    = "/suggestions"
}

module "wordle_solver_ui" {
  source = "./docker-http-service"

  image         = "stephdewit/wordle-solver-ui:0.4.0"
  container     = "wordle-solver-ui"
  internal_port = 80
  network       = docker_network.www.name

  hosts   = [local.wordle_solver_host]
  methods = ["GET"]
}
