resource "aws_cloudfront_origin_access_identity" "pki_cf_identity" {
}

data "aws_iam_policy_document" "pki_cf_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.pki_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.pki_cf_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.pki_bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.pki_cf_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "pki_cf_policy" {
  bucket = aws_s3_bucket.pki_bucket.id
  policy = data.aws_iam_policy_document.pki_cf_policy.json
}

resource "aws_s3_bucket_public_access_block" "pki_public_access_block" {
  bucket = aws_s3_bucket.pki_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}

locals {
  s3_origin_id               = "pki-s3-origin"
  caching_disabled_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
}

resource "aws_cloudfront_distribution" "pki_cf_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  origin {
    origin_id   = local.s3_origin_id
    domain_name = aws_s3_bucket.pki_bucket.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.pki_cf_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    cache_policy_id  = local.caching_disabled_policy_id
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "https-only"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

output "pki_domain_name" {
  value = aws_cloudfront_distribution.pki_cf_distribution.domain_name
}
