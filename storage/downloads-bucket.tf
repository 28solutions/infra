resource "scaleway_object_bucket" "downloads" {
  name = "sdw-downloads"
}

module "downloads_bucket_index" {
  source = "./bucket-index"

  title = "Downloads"
  icon  = "download"
}

resource "scaleway_object" "downloads_index" {
  bucket = scaleway_object_bucket.downloads.id
  key    = "index.html"

  content = module.downloads_bucket_index.content
  hash    = module.downloads_bucket_index.hash
}
