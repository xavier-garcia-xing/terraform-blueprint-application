
output "vpc_id" {
  description = "ID of project VPC from real"
  value       = module.vpc.vpc_id
}

output "provider_arn" {
  description = "openid_provider ARN for github policy document"
  value       = aws_iam_openid_connect_provider.github.arn
}
