resource "scaleway_object_bucket" "downloads" {
  name = "sdw-downloads"
}

resource "scaleway_object_bucket_acl" "downloads_acl" {
  bucket = scaleway_object_bucket.downloads.id
  acl    = "public-read"
}

resource "scaleway_object_bucket_policy" "downloads_policy" {
  bucket = scaleway_object_bucket.downloads.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "DownloadsBucketPolicy"

    Statement = [
      {
        Sid       = "GrantToEveryone"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${scaleway_object_bucket.downloads.name}/*"
      }
    ]
  })
}

resource "scaleway_object" "downloads_index" {
  bucket = scaleway_object_bucket.downloads.id
  key    = "index.html"

  file = "downloads/index.html"
  hash = filemd5("downloads/index.html")
}

resource "scaleway_object_bucket_website_configuration" "downloads_website" {
  bucket = scaleway_object_bucket.downloads.id
  index_document {
    suffix = "index.html"
  }
}

output "downloads_domain_name" {
  value = scaleway_object_bucket_website_configuration.downloads_website.website_endpoint
}
