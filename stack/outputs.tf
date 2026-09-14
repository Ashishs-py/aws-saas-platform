output "application_url" {
  description = "Public entry point for this environment."
  value       = var.enable_cloudfront ? "https://${module.edge.cloudfront_domain_name}" : "http://${module.compute.alb_dns_name}"
}

output "alb_dns_name" { value = module.compute.alb_dns_name }
output "cloudfront_domain_name" { value = module.edge.cloudfront_domain_name }
output "ecr_repository_url" { value = module.ecr.repository_url }
output "ecs_cluster_name" { value = module.compute.cluster_name }
output "ecs_service_name" { value = module.compute.service_name }
output "task_definition_arn" { value = module.compute.task_definition_arn }
output "log_group_name" { value = module.compute.log_group_name }
output "dynamodb_table_name" { value = module.data.table_name }
output "kms_key_arn" { value = module.security.kms_key_arn }
output "alerts_topic_arn" { value = module.observability.sns_topic_arn }
output "dashboard_name" { value = module.observability.dashboard_name }
output "backup_vault_name" { value = try(module.backup[0].vault_name, null) }
output "guardduty_detector_id" { value = module.security.guardduty_detector_id }
output "waf_web_acl_arn" { value = module.edge.web_acl_arn }
output "aws_account_id" { value = data.aws_caller_identity.current.account_id }
output "region" { value = data.aws_region.current.name }
output "size_profile" { value = var.size_profile }

output "deployment_summary" {
  description = "Single object used as deployment evidence in CI."
  value = {
    customer    = var.customer_code
    environment = var.environment
    region      = data.aws_region.current.name
    size        = var.size_profile
    url         = var.enable_cloudfront ? "https://${module.edge.cloudfront_domain_name}" : "http://${module.compute.alb_dns_name}"
    cluster     = module.compute.cluster_name
    service     = module.compute.service_name
    image       = local.app_image
    waf         = var.enable_waf
    backups     = var.enable_backup
    guardduty   = var.enable_guardduty
  }
}
