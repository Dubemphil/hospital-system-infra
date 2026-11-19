# ==============================================================================
# Bootstrap Variables - Remote State & Initial OIDC Federation
# ==============================================================================

variable "aws_region" {
  type        = string
  description = "Target AWS Region for remote state and OIDC provider"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name prefix"
  default     = "hospital-system"
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev, staging, production)"
  default     = "dev"
}

variable "github_org" {
  type        = string
  description = "GitHub organization or user account owning the repositories"
  default     = "Dubemphil"
}

variable "github_infra_repo" {
  type        = string
  description = "Repository name for the Terraform infrastructure"
  default     = "hospital_terraform"
}
