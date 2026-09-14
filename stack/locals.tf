locals {
  # One place to change how every customer environment is sized. Adding a new
  # customer is a tfvars file, not a code change.
  sizing = {
    small = {
      az_count                  = 2
      enable_nat_gateway        = false
      task_cpu                  = 256
      task_memory               = 512
      desired_count             = 1
      min_capacity              = 1
      max_capacity              = 3
      cpu_target_percent        = 65
      use_fargate_spot          = true
      enable_container_insights = false
      log_retention_days        = 7
      backup_retention_days     = 30
      cold_storage_after_days   = 0
      point_in_time_recovery    = true
      deletion_protection       = false
      keep_images               = 10
      latency_threshold_seconds = 2
      error_rate_threshold      = 5
    }
    medium = {
      az_count                  = 2
      enable_nat_gateway        = true
      task_cpu                  = 512
      task_memory               = 1024
      desired_count             = 2
      min_capacity              = 2
      max_capacity              = 6
      cpu_target_percent        = 60
      use_fargate_spot          = false
      enable_container_insights = true
      log_retention_days        = 30
      backup_retention_days     = 120
      cold_storage_after_days   = 30
      point_in_time_recovery    = true
      deletion_protection       = true
      keep_images               = 20
      latency_threshold_seconds = 1
      error_rate_threshold      = 5
    }
    large = {
      az_count                  = 3
      enable_nat_gateway        = true
      task_cpu                  = 1024
      task_memory               = 2048
      desired_count             = 3
      min_capacity              = 3
      max_capacity              = 12
      cpu_target_percent        = 55
      use_fargate_spot          = false
      enable_container_insights = true
      log_retention_days        = 90
      backup_retention_days     = 365
      cold_storage_after_days   = 30
      point_in_time_recovery    = true
      deletion_protection       = true
      keep_images               = 30
      latency_threshold_seconds = 1
      error_rate_threshold      = 10
    }
  }

  size        = local.sizing[var.size_profile]
  name_prefix = "${var.customer_code}-${var.environment}"

  # Until the first application image is published, the platform runs a public
  # placeholder that listens on the same port as the real application, so the
  # first real release is an image change only.
  placeholder_image   = "public.ecr.aws/docker/library/python:3.12-alpine"
  use_placeholder     = var.container_image == ""
  app_image           = local.use_placeholder ? local.placeholder_image : var.container_image
  app_port            = var.container_port
  placeholder_command = ["sh", "-c", "python -m http.server ${var.container_port}"]
  app_command         = local.use_placeholder ? local.placeholder_command : []

  tags = {
    Customer    = var.customer_code
    Environment = var.environment
    SizeProfile = var.size_profile
  }
}
