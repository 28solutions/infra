resource "docker_network" "otel" {
  name = "otel"
}

resource "docker_image" "otel_collector" {
  name         = "otel/opentelemetry-collector-contrib:0.113.0"
  keep_locally = true
}

resource "docker_container" "otel_collector" {
  name    = "otel-collector"
  image   = docker_image.otel_collector.image_id
  restart = "unless-stopped"

  upload {
    file = "/etc/otelcol-contrib/exporters.yaml"
    content = templatefile(
      "otel-collector/exporters.yaml",
      {
        token            = data.terraform_remote_state.provisioning.outputs.traefik_metrics_token
        metrics_endpoint = data.terraform_remote_state.provisioning.outputs.traefik_metrics_push_url
        traces_endpoint  = data.terraform_remote_state.provisioning.outputs.traefik_traces_push_url
      }
    )
  }

  upload {
    file    = "/etc/otelcol-contrib/pipelines.yaml"
    content = file("otel-collector/pipelines.yaml")
  }

  command = [
    "--config", "/etc/otelcol-contrib/config.yaml",
    "--config", "/etc/otelcol-contrib/exporters.yaml",
    "--config", "/etc/otelcol-contrib/pipelines.yaml",
  ]

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.otel.name
  }
}