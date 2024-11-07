data "scaleway_account_project" "project" {}

resource "scaleway_cockpit" "cockpit" {
  project_id = data.scaleway_account_project.project.project_id

  plan = "free"
}

resource "scaleway_cockpit_token" "traefik" {
  project_id = data.scaleway_account_project.project.project_id
  name       = "traefik"

  scopes {
    write_logs = false

    write_metrics = true
    write_traces  = true
  }
}

output "traefik_metrics_token" {
  value     = scaleway_cockpit_token.traefik.secret_key
  sensitive = true
}

resource "scaleway_cockpit_grafana_user" "user" {
  project_id = data.scaleway_account_project.project.project_id

  login = "stephdewit"
  role  = "editor"
}

data "onepassword_vault" "iac_vault" {
  name = "IaC"
}

resource "onepassword_item" "grafana_login" {
  vault = data.onepassword_vault.iac_vault.uuid

  title    = "Scaleway Grafana | www"
  category = "login"

  username = scaleway_cockpit_grafana_user.user.login
  password = scaleway_cockpit_grafana_user.user.password

  url = "https://${scaleway_cockpit_grafana_user.user.project_id}.dashboard.cockpit.fr-par.scw.cloud"
}