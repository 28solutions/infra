resource "aws_s3_bucket" "pki_bucket" {
  bucket = "sdw-pki"
}

resource "aws_s3_bucket_versioning" "pki_versionning" {
  bucket = aws_s3_bucket.pki_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "pki_index" {
  bucket       = aws_s3_bucket.pki_bucket.id
  key          = "index.html"
  source       = "pki/index.html"
  etag         = filemd5("pki/index.html")
  content_type = "text/html"
}
