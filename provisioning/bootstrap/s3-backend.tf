resource "aws_s3_bucket" "state-bucket" {
  bucket = "28s-terraform"
  acl    = "private"

  versioning {
    enabled = true
  }
}
