output "state_bucket" {
  description = "Terraform remote state bucket. Set this as GitHub variable TF_STATE_BUCKET."
  value       = aws_s3_bucket.state.id
}

output "state_region" {
  description = "Region of the state bucket. Set this as GitHub variable TF_STATE_REGION."
  value       = var.state_region
}

output "github_deploy_role_arn" {
  description = "Role ARN for GitHub Actions. Set this as GitHub secret AWS_ROLE_ARN."
  value       = aws_iam_role.github_deploy.arn
}
