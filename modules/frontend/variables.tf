variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for resource naming"
  default     = "hospital-system"
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name of the ALB to route /api traffic directly through CloudFront"
  default     = null
}

variable "kms_key_arn" {
  type        = string
  description = "KMS CMK ARN for S3 bucket encryption"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}

