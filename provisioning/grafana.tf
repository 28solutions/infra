data "scaleway_account_project" "project" {}

resource "scaleway_cockpit_token" "traefik" {
  project_id = data.scaleway_account_project.project.project_id
  name       = "traefik"

  scopes {
    write_logs    = true
    write_metrics = true
    write_traces  = true
  }
}

output "traefik_metrics_token" {
  value     = scaleway_cockpit_token.traefik.secret_key
  sensitive = true
}

resource "scaleway_cockpit_source" "traefik_logs" {
  project_id = data.scaleway_account_project.project.project_id

  name           = "traefik_logs"
  type           = "logs"
  retention_days = 7
}

output "traefik_logs_push_url" {
  value = scaleway_cockpit_source.traefik_logs.push_url
}

resource "scaleway_cockpit_source" "traefik_metrics" {
  project_id = data.scaleway_account_project.project.project_id

  name           = "traefik_metrics"
  type           = "metrics"
  retention_days = 7
}

output "traefik_metrics_push_url" {
  value = scaleway_cockpit_source.traefik_metrics.push_url
}

resource "scaleway_cockpit_source" "traefik_traces" {
  project_id = data.scaleway_account_project.project.project_id

  name           = "traefik_traces"
  type           = "traces"
  retention_days = 7
}

output "traefik_traces_push_url" {
  value = scaleway_cockpit_source.traefik_traces.push_url
}

resource "scaleway_cockpit_grafana_user" "user" {
  project_id = data.scaleway_account_project.project.project_id

  login = "stephdewit"
  role  = "editor"
}

resource "onepassword_item" "grafana_login" {
  vault = data.onepassword_vault.iac_vault.uuid

  title    = "Scaleway Grafana | www"
  category = "login"

  username = scaleway_cockpit_grafana_user.user.login
  password = scaleway_cockpit_grafana_user.user.password

  url = scaleway_cockpit_grafana_user.user.grafana_url
}
