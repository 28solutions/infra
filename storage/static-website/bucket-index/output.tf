resource "time_static" "epoch" {}

locals {
  content = templatefile(
    "${path.module}/public-html/index.html",
    {
      title    = var.title
      icon     = var.icon
      owner    = var.owner
      creation = time_static.epoch.year
    }
  )
}

output "content" {
  value = local.content
}

output "hash" {
  value = md5(local.content)
}
