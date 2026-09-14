variable "name_prefix" { type = string }
variable "vpc_cidr" { type = string }
variable "az_count" { type = number }
variable "enable_nat_gateway" { type = bool }
variable "enable_flow_logs" { type = bool }
variable "log_retention_days" { type = number }
variable "kms_key_arn" { type = string }
variable "tags" { type = map(string) }
