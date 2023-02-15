output "alb_dns_name" {
  value = aws_lb.ecs_service.dns_name
}