resource "aws_s3_bucket" "pki_bucket" {
  bucket = "sdw-pki"
}

resource "aws_s3_bucket_versioning" "pki_versionning" {
  bucket = aws_s3_bucket.pki_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

module "pki_bucket_index" {
  source = "./bucket-index"

  title = "PKI"
  icon  = "key"
}

resource "aws_s3_object" "pki_index" {
  bucket       = aws_s3_bucket.pki_bucket.id
  key          = "index.html"
  content      = module.pki_bucket_index.content
  etag         = module.pki_bucket_index.hash
  content_type = "text/html"
}
