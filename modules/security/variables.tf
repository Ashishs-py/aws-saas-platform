variable "name_prefix" { type = string }
variable "enable_cloudtrail" { type = bool }
variable "enable_guardduty" { type = bool }
variable "enable_security_hub" { type = bool }
variable "log_retention_days" { type = number }
variable "tags" { type = map(string) }
