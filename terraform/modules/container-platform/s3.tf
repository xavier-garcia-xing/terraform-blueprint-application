resource "aws_s3_bucket" "alb_logs" {
  bucket        = format("nw-alb-logs-%s-%s", var.task.application_name, var.environment_name)
  force_destroy = true
}

data "aws_elb_service_account" "alb" {}

data "aws_iam_policy_document" "bucket_policy_alb_access" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.alb_logs.arn}/*",
    ]

    principals {
      identifiers = [data.aws_elb_service_account.alb.arn]
      type        = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.bucket_policy_alb_access.json
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs_encryption" {
  bucket = aws_s3_bucket.alb_logs.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs_retention" {
  bucket = aws_s3_bucket.alb_logs.bucket

  rule {
    id = "log_retention"

    expiration {
      days = 35
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}