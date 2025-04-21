resource "aws_s3_bucket" "state-bucket" {
  bucket = var.bucket

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "state-bucket" {
  bucket = aws_s3_bucket.state-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "state-bucket" {
  bucket = aws_s3_bucket.state-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  depends_on = [aws_s3_bucket_versioning.state-bucket]

  bucket = aws_s3_bucket.state-bucket.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    filter {
      prefix = "states/"
    }

    noncurrent_version_expiration {
      noncurrent_days           = 7
      newer_noncurrent_versions = 5
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 2
    }
  }
}

resource "aws_iam_policy" "policy" {
  name = "TerraformState"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
        ]
        Resource = aws_s3_bucket.state-bucket.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Resource = "${aws_s3_bucket.state-bucket.arn}/states/*.tfstate"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "${aws_s3_bucket.state-bucket.arn}/states/*.tflock"
      },
    ]
  })
}
