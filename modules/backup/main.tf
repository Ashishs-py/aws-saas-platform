resource "aws_backup_vault" "this" {
  name        = "${var.name_prefix}-vault"
  kms_key_arn = var.kms_key_arn
  tags        = var.tags
}

data "aws_iam_policy_document" "backup_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name_prefix        = "${var.name_prefix}-backup-"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_plan" "this" {
  name = "${var.name_prefix}-plan"
  tags = var.tags

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.this.name
    schedule          = var.backup_schedule
    start_window      = 60
    completion_window = 180

    enable_continuous_backup = var.enable_continuous_backup

    lifecycle {
      cold_storage_after = var.cold_storage_after_days > 0 ? var.cold_storage_after_days : null
      delete_after       = var.retention_days
    }

    recovery_point_tags = var.tags
  }
}

# Resources opt in to backup by carrying the Backup=true tag, so new resources
# are protected without touching the backup configuration.
resource "aws_backup_selection" "tagged" {
  name         = "${var.name_prefix}-tagged-resources"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.this.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}
