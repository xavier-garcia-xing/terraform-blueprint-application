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

locals {
  #vpc_id     = data.aws_ssm_parameter.vpc_id.value
  vpc_id_key = format("%s_vpc_id", var.application_infra_name)
}

// read the VPC ID from SSM
data "aws_ssm_parameter" "vpc_id" {
  name = local.vpc_id_key # name of the key for recive the var from setup
}

module "website" {
  source           = "./modules/website"
  application_name = var.application_name
  environment_type = var.environment_type
  environment_name = var.environment_name
}

data "aws_region" "current" {}

#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "nginx" {
  name   = "Nginx"
  vpc_id = data.aws_ssm_parameter.vpc_id.value #module.vpc.vpc_id


  # Allow Docker hub access
  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
/*This module creates a container platform for an application. 
It takes in the application name as a parameter, and sets up a 
container with the name "first" and image "nginx:alpine". The 
container has 1024 CPU and 2048 memory, and is exposed on port 80. 
The log configuration is set up to use AWS logs with the group 
name equal to the application name, 
region equal to the current AWS region, and stream prefix set 
to "webserver". A security group is also applied, as well as a 
health check with path "/", timeout 20 seconds, and interval 
30 seconds.

*/
module "container-platform" {
  source = "./modules/container-platform"
  task = {
    application_name = var.application_name
    container_definitions = jsonencode([
      {
        name      = "first"
        image     = "nginx:alpine"
        cpu       = 1024
        memory    = 2048
        essential = true
        portMappings = [
          {
            containerPort = 80
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            # this needs to be equal to the application_name param
            awslogs-group : var.application_name,
            awslogs-region : data.aws_region.current.name,
            awslogs-stream-prefix : "webserver"
          }
        }
      }
    ])
    exposed_container_name = "first"
    exposed_container_port = 80
    security_groups        = [aws_security_group.nginx.id]
    memory                 = 2048
    cpu                    = 1024
    health_check = {
      path     = "/"
      timeout  = 20
      interval = 30
    }
  }
  environment_type = var.environment_type
  environment_name = var.environment_name
  vpc_id           = data.aws_ssm_parameter.vpc_id.value
}