variable "fargate_capacity_weight" {
  type    = number
  default = 100
}

variable "fargate_spot_capacity_weight" {
  type    = number
  default = 0
}

variable "service_desired_count" {
  type    = number
  default = 1
}

variable "service_wait_for_steady_state" {
  type    = bool
  default = true
}

variable "task_runtime_cpu_architecture" {
  type    = string
  default = "ARM64"
}

// service
variable "task" {
  type = object({
    application_name       = string
    container_definitions  = string
    exposed_container_name = string
    exposed_container_port = number
    security_groups        = list(string)
    memory                 = number
    cpu                    = number
    health_check = object({
      path     = string
      timeout  = number
      interval = number
    })
  })
}

variable "vpc_id" {
  type = string
}


variable "environment_type" {
  type = string
}

variable "environment_name" {
  type = string
}
