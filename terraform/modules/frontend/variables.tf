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

variable "domain_name" {
  type        = string
  description = "Custom root domain name (e.g. devopsstandard.name.ng)"
  default     = null
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate for CloudFront (Must be in us-east-1)"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}
