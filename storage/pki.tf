resource "aws_s3_bucket" "pki_bucket" {
  bucket = "sdw-pki"
}

resource "aws_s3_bucket_versioning" "pki_versionning" {
  bucket = aws_s3_bucket.pki_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "pki_public_access_block" {
  bucket = aws_s3_bucket.pki_bucket.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_policy" "pki_bucket_policy" {
  bucket = aws_s3_bucket.pki_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.pki_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "pki_website" {
  bucket = aws_s3_bucket.pki_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "pki_index" {
  bucket       = aws_s3_bucket.pki_bucket.id
  key          = "index.html"
  source       = "pki/index.html"
  etag         = filemd5("pki/index.html")
  content_type = "text/html"
}
