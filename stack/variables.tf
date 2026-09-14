##########################
# Customer identity
##########################

variable "customer_code" {
  description = "Short code for the customer. Drives resource naming. No customer names in code."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.customer_code))
    error_message = "customer_code must be 2-12 lowercase letters, digits or hyphens."
  }
}

variable "environment" {
  description = "Environment name: dev, test or prod."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of dev, test, prod."
  }
}

variable "aws_region" {
  description = "Region this environment is deployed into."
  type        = string
}

variable "project_name" {
  description = "Platform name used for tagging."
  type        = string
  default     = "saas-platform"
}

variable "repository" {
  description = "Source repository, recorded as a tag for traceability."
  type        = string
  default     = "aws-saas-platform"
}

##########################
# Sizing
##########################

variable "size_profile" {
  description = "T-shirt size for the environment: small, medium or large."
  type        = string
  default     = "small"

  validation {
    condition     = contains(["small", "medium", "large"], var.size_profile)
    error_message = "size_profile must be one of small, medium, large."
  }
}

##########################
# Networking
##########################

variable "vpc_cidr" {
  description = "CIDR block for the customer VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "ingress_cidrs" {
  description = "Client CIDRs allowed to reach the load balancer."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

##########################
# Application
##########################

variable "container_image" {
  description = "Container image to run. Empty uses a public placeholder so the platform can be deployed before the first application build."
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Port the application listens on."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Load balancer health check path."
  type        = string
  default     = "/"
}

##########################
# Feature toggles
##########################

variable "enable_waf" {
  type    = bool
  default = true
}

variable "enable_cloudfront" {
  type    = bool
  default = false
}

variable "enable_account_baseline" {
  description = "Create the account level security baseline (CloudTrail) from this stack. Enable once per AWS account."
  type        = bool
  default     = false
}

variable "enable_guardduty" {
  type    = bool
  default = true
}

variable "enable_security_hub" {
  type    = bool
  default = false
}

variable "enable_backup" {
  type    = bool
  default = true
}

##########################
# Operations
##########################

variable "alarm_email" {
  description = "Address subscribed to the alert topic. Leave empty to skip the subscription."
  type        = string
  default     = ""
}

variable "backup_schedule" {
  description = "Cron expression for the daily backup window (UTC)."
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "waf_rate_limit" {
  description = "Requests per five minutes per source IP before blocking."
  type        = number
  default     = 2000
}
