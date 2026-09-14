module "security" {
  source = "../modules/security"

  name_prefix         = local.name_prefix
  enable_cloudtrail   = var.enable_account_baseline
  enable_guardduty    = var.enable_guardduty
  enable_security_hub = var.enable_security_hub
  log_retention_days  = local.size.log_retention_days
  tags                = local.tags
}

module "network" {
  source = "../modules/network"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  az_count           = local.size.az_count
  enable_nat_gateway = local.size.enable_nat_gateway
  enable_flow_logs   = true
  log_retention_days = local.size.log_retention_days
  kms_key_arn        = module.security.kms_key_arn
  tags               = local.tags
}

module "data" {
  source = "../modules/data"

  name_prefix            = local.name_prefix
  kms_key_arn            = module.security.kms_key_arn
  point_in_time_recovery = local.size.point_in_time_recovery
  deletion_protection    = local.size.deletion_protection
  tags                   = local.tags
}

module "ecr" {
  source = "../modules/ecr"

  name_prefix = local.name_prefix
  kms_key_arn = module.security.kms_key_arn
  keep_images = local.size.keep_images
  tags        = local.tags
}

##########################
# Application secret
##########################

resource "random_password" "app_secret" {
  length  = 32
  special = false
}

resource "random_id" "origin_header" {
  byte_length = 16
}

resource "aws_secretsmanager_secret" "app" {
  name_prefix             = "${local.name_prefix}/app/"
  description             = "Application runtime secret for ${local.name_prefix}"
  kms_key_id              = module.security.kms_key_arn
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = random_password.app_secret.result

  lifecycle {
    ignore_changes = [secret_string]
  }
}

module "compute" {
  source = "../modules/compute"

  name_prefix       = local.name_prefix
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  app_subnet_ids    = module.network.app_subnet_ids
  assign_public_ip  = module.network.app_assign_public_ip
  ingress_cidrs     = var.ingress_cidrs

  container_image           = local.app_image
  container_command         = local.app_command
  container_port            = local.app_port
  task_cpu                  = local.size.task_cpu
  task_memory               = local.size.task_memory
  desired_count             = local.size.desired_count
  min_capacity              = local.size.min_capacity
  max_capacity              = local.size.max_capacity
  cpu_target_percent        = local.size.cpu_target_percent
  use_fargate_spot          = local.size.use_fargate_spot
  enable_container_insights = local.size.enable_container_insights

  health_check_path   = var.health_check_path
  log_retention_days  = local.size.log_retention_days
  kms_key_arn         = module.security.kms_key_arn
  app_secret_arn      = aws_secretsmanager_secret.app.arn
  dynamodb_table_name = module.data.table_name
  dynamodb_table_arn  = module.data.table_arn

  enable_cloudfront   = var.enable_cloudfront
  origin_header_name  = "x-origin-verify"
  origin_header_value = random_id.origin_header.hex

  tags = local.tags
}

module "edge" {
  source = "../modules/edge"

  name_prefix         = local.name_prefix
  enable_waf          = var.enable_waf
  enable_cloudfront   = var.enable_cloudfront
  alb_arn             = module.compute.alb_arn
  alb_dns_name        = module.compute.alb_dns_name
  waf_rate_limit      = var.waf_rate_limit
  origin_header_name  = "x-origin-verify"
  origin_header_value = random_id.origin_header.hex
  log_retention_days  = local.size.log_retention_days
  tags                = local.tags
}

module "observability" {
  source = "../modules/observability"

  name_prefix               = local.name_prefix
  kms_key_arn               = module.security.kms_key_arn
  alarm_email               = var.alarm_email
  alb_arn_suffix            = module.compute.alb_arn_suffix
  target_group_arn_suffix   = module.compute.target_group_arn_suffix
  cluster_name              = module.compute.cluster_name
  service_name              = module.compute.service_name
  log_group_name            = module.compute.log_group_name
  dynamodb_table_name       = module.data.table_name
  latency_threshold_seconds = local.size.latency_threshold_seconds
  error_rate_threshold      = local.size.error_rate_threshold
  enable_guardduty_alerts   = var.enable_guardduty
  tags                      = local.tags
}

module "backup" {
  source = "../modules/backup"
  count  = var.enable_backup ? 1 : 0

  name_prefix              = local.name_prefix
  kms_key_arn              = module.security.kms_key_arn
  backup_schedule          = var.backup_schedule
  retention_days           = local.size.backup_retention_days
  cold_storage_after_days  = local.size.cold_storage_after_days
  enable_continuous_backup = false
  tags                     = local.tags
}
