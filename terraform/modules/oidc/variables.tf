variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for resource naming"
  default     = "hospital-system"
}

variable "github_org" {
  type        = string
  description = "GitHub organization or username (e.g. Dubemphil)"
  default     = "Dubemphil"
}

variable "github_backend_repo" {
  type        = string
  description = "Backend repository name"
  default     = "hospital-system-backend"
}

variable "github_frontend_repo" {
  type        = string
  description = "Frontend repository name"
  default     = "hospital-system-frontend"
}

variable "github_infra_repo" {
  type        = string
  description = "Infrastructure repository name"
  default     = "hospital-system-infra"
}

variable "ecr_repository_arn" {
  type        = string
  description = "ARN of the ECR repository"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of the ECS Cluster"
}

variable "ecs_service_arn" {
  type        = string
  description = "ARN of the ECS Service"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the ECS task execution role"
}

variable "ecs_task_role_arn" {
  type        = string
  description = "ARN of the ECS task role"
}

variable "frontend_bucket_arn" {
  type        = string
  description = "ARN of the frontend S3 bucket"
}

variable "cloudfront_distribution_arn" {
  type        = string
  description = "ARN of the CloudFront distribution"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}

