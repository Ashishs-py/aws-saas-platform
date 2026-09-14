terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = var.state_region

  default_tags {
    tags = {
      Project   = "aws-saas-platform"
      Component = "bootstrap"
      ManagedBy = "terraform"
    }
  }
}
