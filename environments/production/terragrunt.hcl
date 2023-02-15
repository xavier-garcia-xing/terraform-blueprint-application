terraform {
  source = "../..//terraform"
}

locals {
  environment_type = "production"
  environment_name = "prod"
  application_name = "terraform-blueprint-application"
  account_id       = get_aws_account_id()
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "nw-bucket-terraform-state-nw-${local.account_id}-${local.environment_name}" # bucket names need to be unique
    key            = "${local.application_name}/${local.environment_name}/terraform.tfstate"      # <APPLICATION>/<ENVIRONMENT>/terraform.tfstate
    region         = "eu-central-1"
    dynamodb_table = "nw-ddbtable-terraform-state"
    #profile = "saml"
    encrypt = true
    acl     = "private"
  }
}

prevent_destroy = true

inputs = {
  application_name = local.application_name
  environment_type = local.environment_type
  environment_name = local.environment_name
  network = {
    #vpc_cidr        = "172.16.0.0/16"
    azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
    #private_subnets = ["172.16.10.0/24", "172.16.20.0/24", "172.16.30.0/24"]
    #public_subnets  = ["172.16.100.0/24", "172.16.120.0/24", "172.16.130.0/24"]
  }
}
