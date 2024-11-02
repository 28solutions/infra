resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.bucket_versioning ? "Enabled" : "Disabled"
  }
}

module "bucket_index" {
  source = "../bucket-index"

  title = var.title
  icon  = var.icon
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.bucket.id
  key          = "index.html"
  content      = module.bucket_index.content
  etag         = module.bucket_index.hash
  content_type = "text/html"
}
