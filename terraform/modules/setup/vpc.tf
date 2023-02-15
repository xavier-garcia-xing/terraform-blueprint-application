### Lets create a VPC using the official AWS vpc module
### To avoid overlapping IP addressing when connecting to our DC,
### DO NOT USE 10.0.0.0/8 network ranges.
#tfsec:ignore:aws-ec2-no-public-ip-subnet
#tfsec:ignore:aws-ec2-no-public-ingress-acl
#tfsec:ignore:aws-ec2-no-excessive-port-access
module "vpc" {
  source                        = "terraform-aws-modules/vpc/aws"
  version                       = "3.19.0"
  name                          = "nw-vpc-microservice"
  cidr                          = var.network.vpc_cidr
  azs                           = var.network.azs
  private_subnets               = var.network.private_subnets
  public_subnets                = var.network.public_subnets
  enable_nat_gateway            = true
  single_nat_gateway            = true
  enable_dns_hostnames          = true
  manage_default_security_group = true
  
  public_subnet_tags = {
    tier = "public"
  }

  private_subnet_tags = {
    tier = "private"
  }
  
}
#Introduce vpc in ssm service of aws to share with other modules
resource "aws_ssm_parameter" "vpc_id" {
  name        = format("%s_vpc_id", var.application_name)
  description = format("VPC id for workload %s", var.application_name)
  type        = "String"
  value       = module.vpc.vpc_id
}