variable "name_prefix" { type = string }
variable "enable_waf" { type = bool }
variable "enable_cloudfront" { type = bool }
variable "alb_arn" { type = string }
variable "alb_dns_name" { type = string }
variable "waf_rate_limit" { type = number }
variable "origin_header_name" { type = string }
variable "origin_header_value" {
  type      = string
  sensitive = true
}
variable "log_retention_days" { type = number }
variable "tags" { type = map(string) }
