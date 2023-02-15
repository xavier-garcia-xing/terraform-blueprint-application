variable "application_name" {
  type = string

  validation {
    condition     = length(var.application_name) > 0
    error_message = "Provide your application name."
  }
}

variable "environment_type" {
  type = string

  validation {
    condition     = contains(["production", "sandbox", "staging"], var.environment_type)
    error_message = "Provide valid environment (production, sandbox, staging)."
  }
}

variable "environment_name" {
  type = string

  validation {
    condition     = length(var.environment_name) > 0
    error_message = "Provide meaningful environment name."
  }
}

variable "network" {
  type = object({
    vpc_cidr        = string
    azs             = set(string)
    private_subnets = set(string)
    public_subnets  = set(string)
  })
  validation {
    condition     = can(cidrhost(var.network.vpc_cidr, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "account_id" {
  type = number

  validation {
    condition     = var.account_id > 0
    error_message = "Provide rightful account_id."
  }
}


variable "deployment_version" {
  type = string

  validation {
    error_message = "Must be valid semantic version. i.e:10.57.123"
    condition     = can(regex("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$", var.deployment_version))
  }
}


variable "git_repo_root" {
  type    = string
  default = "github.com"
}

variable "git_domain" {
  type = string
}