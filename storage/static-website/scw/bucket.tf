resource "scaleway_object_bucket" "bucket" {
  name = var.bucket

  versioning {
    enabled = var.bucket_versioning
  }
}

module "bucket_index" {
  source = "../bucket-index"

  title = var.title
  icon  = var.icon
}

resource "scaleway_object" "index" {
  bucket = scaleway_object_bucket.bucket.id
  key    = "index.html"

  content = module.bucket_index.content
  hash    = module.bucket_index.hash
}
