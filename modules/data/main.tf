# DynamoDB on-demand is chosen over RDS for this workload profile:
# no idle instance cost, no patching, no Multi-AZ failover to operate, and it
# scales with traffic automatically. Swap this module for an RDS module when a
# customer needs relational features.
resource "aws_dynamodb_table" "app" {
  name         = "${var.name_prefix}-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  deletion_protection_enabled = var.deletion_protection

  tags = merge(var.tags, {
    Name   = "${var.name_prefix}-items"
    Backup = "true"
  })
}
