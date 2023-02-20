/*
This code creates an Amazon Elastic Container Service (ECS) 
task definition resource. The task definition is named "ecs_app" 
and is created with the family name specified by the variable 
"application_name". The container definitions, CPU, memory, and 
execution role ARN are also specified by variables. The network 
mode is set to "awsvpc" and the runtime platform is set to Linux 
with a CPU architecture specified by a variable.
*/
resource "aws_ecs_task_definition" "ecs_app" {
  family                   = var.task.application_name
  container_definitions    = var.task.container_definitions
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task.cpu
  memory                   = var.task.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.task_runtime_cpu_architecture
  }
}

resource "aws_cloudwatch_log_group" "ecs_logging" {
  name              = var.task.application_name
  retention_in_days = 5
}

resource "aws_security_group" "alb_to_service" {
  name   = "Allow connections from ALB"
  vpc_id = var.vpc_id
  ingress {
    from_port       = var.task.exposed_container_port
    protocol        = "tcp"
    to_port         = var.task.exposed_container_port
    security_groups = aws_lb.ecs_service.security_groups
  }
}

resource "aws_ecs_service" "ecs_app" {
  name            = var.task.application_name
  cluster         = aws_ecs_cluster.container_platform.id
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.ecs_app.arn

  network_configuration {
    subnets         = data.aws_subnets.private.ids
    security_groups = concat(var.task.security_groups, [aws_security_group.alb_to_service.id])
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = var.task.exposed_container_name
    container_port   = var.task.exposed_container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb.ecs_service]
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
      "elasticloadbalancing:CreateLoadBalancer",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "iam:CreateServiceLinkedRole",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "iam:CreateServiceLinkedRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = format("%s-ecsTaskExecutionRole", var.task.application_name)
  description        = "ECS role to allow container execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.container_platform.name}/${aws_ecs_service.ecs_app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 75
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}