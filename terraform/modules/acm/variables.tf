variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
}

variable "project_name" {
  type        = string
  description = "Project name prefix"
  default     = "hospital-system"
}

variable "domain_name" {
  type        = string
  description = "Root custom domain name (e.g. devopsstandard.name.ng)"
  default     = "devopsstandard.name.ng"
}

variable "api_subdomain" {
  type        = string
  description = "API subdomain name (e.g. api.devopsstandard.name.ng)"
  default     = "api.devopsstandard.name.ng"
}

variable "manage_route53" {
  type        = bool
  description = "Whether Route 53 manages the hosted zone and should auto-create DNS records"
  default     = false
}

variable "cloudfront_domain_name" {
  type        = string
  description = "Domain name of the CloudFront distribution for Route 53 alias record"
  default     = null
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name of the ALB for Route 53 alias record"
  default     = null
}

variable "alb_zone_id" {
  type        = string
  description = "Hosted zone ID of the ALB for Route 53 alias record"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}
