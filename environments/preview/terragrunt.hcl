terraform {
  source = "../..//terraform"
}

locals {
  environment_type = "staging"
  environment_name = "preview"
 # it has to be less than 24 characters by alb and other aws element (32 chars) for aws limits
  application_name = "terraform-blueprint-app"
  application_repo_name = "terraform-blueprint-application"
  application_infra_name = "terraform-blueprint-infra"
  /*get_aws_account_id() is a function that retrieves the AWS account ID
   associated with the current user. It returns a string containing the 
   AWS account ID. It is neccesaty the env var AWS_DEFAULT_REGION or to 
   have proper defined  the region var */
  account_id       = get_aws_account_id()
  deployment_version = "1.0.0"
  git_domain         = "github.com"
  git_repo_root      = "xavier-garcia-xing"
  dynamodb_table_tf  ="nw-ddbtable-terraform-state"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "nw-bucket-terraform-state-nw-${local.account_id}-${local.environment_name}" # bucket names need to be unique
    key            = "${local.application_name}/${local.environment_name}/terraform.tfstate"      # <APPLICATION>/<ENVIRONMENT>/terraform.tfstate
    region         = "eu-central-1"
    dynamodb_table = "${local.dynamodb_table_tf}"
    #profile = "saml"
    encrypt = true
    acl     = "private"
  }
}

prevent_destroy = false 

inputs = {
  application_name = local.application_name
  application_infra_name = local.application_infra_name
  application_repo_name = local.application_repo_name
  environment_type = local.environment_type
  environment_name = local.environment_name
  network = {
    vpc_cidr        = "10.5.31.0/24"
    azs             = ["eu-central-1a", "eu-central-1b"]
    private_subnets = ["10.5.31.0/26", "10.5.31.64/26"]
    public_subnets  = ["10.5.31.128/26", "10.5.31.192/26"]
  }
  account_id          = local.account_id
  deployment_version  = local.deployment_version
  git_domain          = local.git_domain
  git_repo_root       = local.git_repo_root
  dynamodb_table_tf   = local.dynamodb_table_tf
}
