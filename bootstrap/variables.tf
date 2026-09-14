variable "org_prefix" {
  description = "Short prefix used to name shared platform resources (no customer names)."
  type        = string
}

variable "state_region" {
  description = "Region that hosts the shared Terraform state bucket."
  type        = string
}

variable "github_owner" {
  description = "GitHub organisation or user that owns the repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name that is allowed to assume the deployment role."
  type        = string
}

variable "allowed_branches" {
  description = "Branches allowed to assume the deployment role."
  type        = list(string)
  default     = ["main"]
}

variable "create_oidc_provider" {
  description = "Set to false if the GitHub OIDC provider already exists in this AWS account."
  type        = bool
  default     = true
}

variable "deploy_policy_arn" {
  description = "Managed policy attached to the CI deployment role. Replace with a scoped policy for production."
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}
