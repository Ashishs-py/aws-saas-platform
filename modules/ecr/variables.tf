variable "name_prefix" { type = string }
variable "kms_key_arn" { type = string }
variable "keep_images" { type = number }
variable "tags" { type = map(string) }
