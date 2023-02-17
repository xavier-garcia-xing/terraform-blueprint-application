output "website_domain_name" {
  value = module.website.website_domain_name
}

output "container_domain_name" {
  value = module.container-platform.alb_dns_name
}