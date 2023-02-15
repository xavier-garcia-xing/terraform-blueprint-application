output "website_domain_name" {
  value = module.website.website_domain_name
}

output "container_domain_name" {
  value = module.container-platform.alb_dns_name
}

/*output "network" {
  description = "network info"  
  value = "${data.terraform_remote_state.network}"
}*/

output "vpc" {
  description = "ID of project VPC from remote state"
  value = "${data.terraform_remote_state.vpc.outputs}"
}
/*output "vpc_id" {
  description = "ID of project VPC from real"
  value = "${module.vpc.vpc_id}"
}*/