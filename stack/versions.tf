terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Partial backend: bucket, key and region are supplied per customer and
  # environment at init time, so no account specific values live in the code.
  backend "s3" {}
}
