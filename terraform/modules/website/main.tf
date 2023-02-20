locals {
  website_bucket_name = "nw-bucket-${var.application_name}-${var.environment_name}-website"
  logging_bucket_name = "nw-bucket-${var.application_name}-${var.environment_name}-access-log"
  website_origin_id   = "nw-origin-${var.application_name}-${var.environment_name}-website"
}

#### S3 bucket for our website
resource "aws_s3_bucket" "website" {
  bucket = local.website_bucket_name
  tags = {
     data_classification= "public"
  }
}

### S3 website bucket acl
resource "aws_s3_bucket_acl" "website" {
  bucket = aws_s3_bucket.website.id
  acl    = "private"
}

### Server side encryption for website bucket
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

### Lifecycle rules for the website bucket
resource "aws_s3_bucket_lifecycle_configuration" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    id     = "root"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

### Enable S3 Versioning
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}

#### Disallow public website bucket
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#### S3 bucket for access logs
resource "aws_s3_bucket" "access_log" {
  bucket        = local.logging_bucket_name
  force_destroy = true
  tags = {
     data_classification= "private"
  }
}

### S3 access_log bucket acl
resource "aws_s3_bucket_acl" "access_log" {
  bucket = aws_s3_bucket.access_log.id
  acl    = "log-delivery-write"
}

### Server side encryption for access_log bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "access_log" {
  bucket = aws_s3_bucket.access_log.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

### Lifecycle rules for the S3 access logs
resource "aws_s3_bucket_lifecycle_configuration" "access_log" {
  bucket = aws_s3_bucket.access_log.id
  rule {
    id     = "log"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {
      prefix = "log/"
    }
  }
}

#### Disallow public logging bucket
resource "aws_s3_bucket_public_access_block" "access_log" {
  bucket = aws_s3_bucket.access_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#### Cloudfront origin identity
resource "aws_cloudfront_origin_access_identity" "origin_identity" {
  comment = "Cloudfront identity for ${var.application_name}"
}

data "aws_iam_policy_document" "cloudfront_website_access" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_website_policy" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.cloudfront_website_access.json
}

#### Cloudfront Cache Policy
resource "aws_cloudfront_cache_policy" "website-cache-policy" {
  name        = "website-default-cache-policy"
  min_ttl     = 3600
  max_ttl     = 31536000
  default_ttl = 86400
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }

    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}

#### Cloudfront Origin Request Policy
resource "aws_cloudfront_origin_request_policy" "website-origin-request-policy" {
  name = "website-origin-request-policy"
  cookies_config {
    cookie_behavior = "none"
  }
  headers_config {
    header_behavior = "none"
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}

#### Cloudfront response header definition
resource "aws_cloudfront_response_headers_policy" "website" {
  name = "security-headers-policy"

  security_headers_config {
    strict_transport_security {
      override                   = false
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
    }

    xss_protection {
      override   = false
      mode_block = true
      protection = true
    }
  }
}

#### Cloudfront distribution for our website
#tfsec:ignore:aws-cloudfront-enable-waf
resource "aws_cloudfront_distribution" "website" {
  # wait_for_deployment = false
  enabled             = true
  comment             = "Cloudfront distribution for ${var.application_name}"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.access_log.bucket_domain_name
    prefix          = "log/"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  origin {
    origin_id   = local.website_origin_id
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.website_origin_id
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 7200

    cache_policy_id            = aws_cloudfront_cache_policy.website-cache-policy.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.website-origin-request-policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.website.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

output "website_domain_name" {
  value = aws_cloudfront_distribution.website.domain_name
}
