variable "name_prefix" { type = string }
variable "kms_key_arn" { type = string }
variable "alarm_email" { type = string }
variable "alb_arn_suffix" { type = string }
variable "target_group_arn_suffix" { type = string }
variable "cluster_name" { type = string }
variable "service_name" { type = string }
variable "log_group_name" { type = string }
variable "dynamodb_table_name" { type = string }
variable "latency_threshold_seconds" { type = number }
variable "error_rate_threshold" { type = number }
variable "tags" { type = map(string) }

variable "enable_guardduty_alerts" {
  type    = bool
  default = true
}
