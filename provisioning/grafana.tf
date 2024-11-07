data "scaleway_account_project" "project" {}

resource "scaleway_cockpit" "cockpit" {
  project_id = data.scaleway_account_project.project.project_id

  plan = "free"
}
