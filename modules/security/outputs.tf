output "kms_key_arn" { value = aws_kms_key.this.arn }
output "kms_key_id" { value = aws_kms_key.this.key_id }
output "kms_alias" { value = aws_kms_alias.this.name }
output "cloudtrail_bucket" { value = try(aws_s3_bucket.trail[0].id, null) }
output "guardduty_detector_id" { value = try(aws_guardduty_detector.this[0].id, null) }
