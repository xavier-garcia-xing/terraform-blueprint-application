
output "vpc_id" {
  description = "ID of project VPC from real"
  value = "${module.vpc.vpc_id}"
}