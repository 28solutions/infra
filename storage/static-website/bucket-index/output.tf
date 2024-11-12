locals {
  content = templatefile(
    "${path.module}/public_html/index.html",
    {
      title = var.title
      icon  = var.icon
      owner = var.owner
    }
  )
}

output "content" {
  value = local.content
}

output "hash" {
  value = md5(local.content)
}
