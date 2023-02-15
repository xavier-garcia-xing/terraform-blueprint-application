#tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "ecs_service" {
  name               = format("nw-alb-%s", var.task.application_name)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_ecs_service.id]
  subnets            = data.aws_subnets.public.ids

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = format("nw-alb-%s", var.task.application_name)
    enabled = true
  }
}

#tfsec:ignore:aws-ec2-no-public-ingress-sgr
resource "aws_security_group" "alb_ecs_service" {
  name   = format("nw-alb-%s", var.task.application_name)
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol        = "tcp"
    from_port       = var.task.exposed_container_port
    to_port         = var.task.exposed_container_port
    security_groups = var.task.security_groups
  }
}

resource "aws_alb_target_group" "main" {
  name        = var.task.application_name
  port        = var.task.exposed_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = var.task.health_check.interval
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = var.task.health_check.timeout
    path                = var.task.health_check.path
    unhealthy_threshold = "3"
  }
}

#tfsec:ignore:aws-elb-http-not-used
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_service.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }

  /*
  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  */
}

/*
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.ecs_service.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = var.alb_tls_cert_arn

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}
*/