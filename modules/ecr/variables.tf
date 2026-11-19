variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for resource naming"
  default     = "hospital-system"
}

variable "repository_name" {
  type        = string
  description = "Name of the ECR repository"
  default     = "hospital-system-backend"
}

variable "image_tag_mutability" {
  type        = string
  description = "The tag mutability setting for the repository"
  default     = "MUTABLE"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS CMK ARN for ECR repository encryption"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}
