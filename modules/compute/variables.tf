variable "name_prefix" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "app_subnet_ids" { type = list(string) }
variable "assign_public_ip" { type = bool }
variable "ingress_cidrs" { type = list(string) }

variable "container_image" { type = string }
variable "container_command" {
  type    = list(string)
  default = []
}
variable "container_port" { type = number }
variable "task_cpu" { type = number }
variable "task_memory" { type = number }
variable "desired_count" { type = number }
variable "min_capacity" { type = number }
variable "max_capacity" { type = number }
variable "cpu_target_percent" { type = number }
variable "use_fargate_spot" { type = bool }
variable "enable_container_insights" { type = bool }

variable "health_check_path" { type = string }
variable "log_retention_days" { type = number }
variable "kms_key_arn" { type = string }
variable "app_secret_arn" { type = string }
variable "dynamodb_table_name" { type = string }
variable "dynamodb_table_arn" { type = string }

variable "enable_cloudfront" { type = bool }
variable "origin_header_name" { type = string }
variable "origin_header_value" {
  type      = string
  sensitive = true
}

variable "tags" { type = map(string) }
