variable "name_prefix" { type = string }
variable "kms_key_arn" { type = string }
variable "backup_schedule" { type = string }
variable "retention_days" { type = number }
variable "cold_storage_after_days" { type = number }
variable "enable_continuous_backup" { type = bool }
variable "tags" { type = map(string) }
