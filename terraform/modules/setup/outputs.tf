/*output "network" {
  description = "network info"  
  value = "${data.terraform_remote_state.network}"
}*/

/*output "vpc" {
  description = "ID of project VPCfrom remote state"
  value = "${data.terraform_remote_state.vpc.outputs}"
}*/
output "vpc_id" {
  description = "ID of project VPC from real"
  value = "${module.vpc.vpc_id}"
}