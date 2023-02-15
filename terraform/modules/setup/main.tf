/*terraform {
  backend "s3" {
    bucket  = "nw-bucket-terraform-state-nw-1746328-production"
    key     = "cpt/initialize/cpt-registry/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
    acl     = "private"
  }
}*/
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"

    }
  }

  # Backend is defined in the Terragrunt configuration
  # See ../environments/staging/terragrunt.hcl
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-central-1"

  # Provide tags for all resources maintained by Terraform
  # See https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html#tag-categories
  default_tags {
    tags = local.default_tags
  }
}
/*
locals {
 bucket         = "nw-bucket-terraform-state-nw-${var.account_id}-${var.environment_name}" # bucket names need to be unique
 key            = "${var.application_name}/${var.environment_name}/terraform.tfstate"      # <APPLICATION>/<ENVIRONMENT>/terraform.tfstate
 region         = "eu-central-1"
}
*/



/*provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      application      = "cpt-container-registry"
      environment_type = "production"
      environment_name = "prod"
      contact_email    = "cpt@new-work.se"
      team_name        = "cloud platform team"
      business_unit    = "petrol"
      cost_center      = "50012"
      provisioned_by   = "terraform"
    }
  }
}*/
/*
locals {
  lock_key_id = "LockID"
}

resource "aws_s3_bucket" "state" {
  bucket        = "nw-bucket-terraform-state-nw-${var.account_id}-${var.environment_name}"
  force_destroy = false
}

resource "aws_s3_bucket_acl" "state" {
  bucket = aws_s3_bucket.state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}*/
/*
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "lock" {
  name         = "nw-ddbtable-terraform-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = local.lock_key_id

  attribute {
    name = local.lock_key_id
    type = "S"
  }
}*/