variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for resource naming"
  default     = "hospital-system"
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "dental_management_system"
}

variable "db_username" {
  type        = string
  description = "Database master username"
  default     = "hospital_app_user"
}

variable "db_password" {
  type        = string
  description = "Database master password"
  sensitive   = true
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
  default     = 20
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum storage limit for autoscaling in GB"
  default     = 100
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment for high availability"
  default     = false
}

variable "backup_retention_days" {
  type        = number
  description = "Days to retain automated DB backups (HIPAA requires at least 7-30)"
  default     = 7
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot upon deletion (set true for testing/dev, false for prod)"
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "Prevent accidental deletion of RDS database"
  default     = false
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of isolated subnet IDs for DB Subnet Group"
}

variable "security_group_id" {
  type        = string
  description = "Security Group ID allowing ECS task access"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS CMK ARN for storage encryption"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}

