provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Customer    = var.customer_code
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      Repository  = var.repository
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
