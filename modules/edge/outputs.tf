output "web_acl_arn" { value = try(aws_wafv2_web_acl.this[0].arn, null) }
output "cloudfront_domain_name" { value = try(aws_cloudfront_distribution.this[0].domain_name, null) }
output "cloudfront_distribution_id" { value = try(aws_cloudfront_distribution.this[0].id, null) }
