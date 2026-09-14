variable "name_prefix" { type = string }
variable "kms_key_arn" { type = string }
variable "point_in_time_recovery" { type = bool }
variable "deletion_protection" { type = bool }
variable "tags" { type = map(string) }
