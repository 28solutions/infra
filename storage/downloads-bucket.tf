resource "scaleway_object_bucket" "downloads" {
  name = "sdw-downloads"
}

resource "scaleway_object" "downloads_index" {
  bucket = scaleway_object_bucket.downloads.id
  key    = "index.html"

  file = "downloads/index.html"
  hash = filemd5("downloads/index.html")
}
