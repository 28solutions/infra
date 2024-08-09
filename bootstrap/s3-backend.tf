resource "aws_s3_bucket" "state-bucket" {
  bucket = "28s-terraform"

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

resource "aws_dynamodb_table" "state-table" {
  name         = "TerraformStateLocks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
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
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
        ]
        Resource = aws_dynamodb_table.state-table.arn
      },
    ]
  })
}
