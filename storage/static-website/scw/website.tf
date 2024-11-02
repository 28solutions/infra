resource "scaleway_object_bucket_acl" "acl" {
  bucket = scaleway_object_bucket.bucket.id
  acl    = "public-read"
}

resource "scaleway_object_bucket_policy" "policy" {
  bucket = scaleway_object_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.bucket}BucketPolicy"

    Statement = [
      {
        Sid       = "GrantToEveryone"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${scaleway_object_bucket.bucket.name}/*"
      }
    ]
  })
}

resource "scaleway_object_bucket_website_configuration" "website" {
  bucket = scaleway_object_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
}
