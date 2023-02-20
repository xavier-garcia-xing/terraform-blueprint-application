variable "application_name" {
  type = string
  validation {
    # TO_CHANGE: size < 35
    condition     = length(var.application_name) > 0
    error_message = "Provide your application name."
  }
}

variable "application_repo_name" {
  type = string
  validation {
    condition     = length(var.application_repo_name) > 0
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

variable "region" {
  type        = string
  description = "AWS Region"
}
/*

variable "vpc_id" {
  type = string
}
variable "ssm_parameters" {
  type        = list
  #default     = [local.openid_connect_provider_key,local.vpc_id_key]
  description = "List of SSM parameters to apply the actions. A parameter can include a path and a name pattern that you define by using forward slashes, e.g. `kops/secret-*`"
}

variable "condition" {
  description = "Github conditions to apply to the AWS Role. E.g. from which org/repo/branch is it allowed to be run."
  type        = string
}

variable "policy_arn" {
  description = "List of ARNs of IAM policies to attach to IAM role."
  type        = list(string)
}

variable "role_max_sessions_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role."
  type        = number
  validation {
    condition     = var.role_max_sessions_duration >= 3600 && var.role_max_sessions_duration <= 43200
    error_message = "Maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 3600 seconds to 43200 seconds."
  }
  default = 3600
}

variable "role_name" {
  description = "The name of the AWS Role which will be used to run Github Actions."
  type        = string
  validation {
    condition     = can(regex("^[\\w+=,.@-]{1,64}$", var.role_name))
    error_message = "Role name is invalid, only alphanumeric characters, the special characters: +=,.@- are allowed and it should be between 1 and 64 characters long."
  }
}

variable "role_permission_boundary" {
  description = "Boundary for the created role."
  type        = string
  default     = null
}*/