/* This module configure vpc, right and all this stuffs that shoud be manage by admin team, not by the BU teams. 
   it create policies, roles, providers and vpc.
*/
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


