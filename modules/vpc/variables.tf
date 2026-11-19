variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for resource naming"
  default     = "hospital-system"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to spread subnets across"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (ALB & NAT)"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private app subnets (ECS Fargate)"
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "isolated_db_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for isolated DB subnets (RDS MySQL)"
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN for VPC Flow Logs encryption"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}

