locals {
  cluster_name = format("nw-fargate-%s", var.task.application_name)
}

resource "aws_ecs_cluster" "container_platform" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "container_platform" {
  cluster_name = aws_ecs_cluster.container_platform.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = var.fargate_capacity_weight
    capacity_provider = "FARGATE"
  }

  default_capacity_provider_strategy {
    weight            = var.fargate_spot_capacity_weight
    capacity_provider = "FARGATE_SPOT"
  }
}