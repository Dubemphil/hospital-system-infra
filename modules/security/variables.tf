variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for resource naming"
  default     = "hospital-system"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}

variable "container_port" {
  type        = number
  description = "Port exposed by the backend container"
  default     = 8080
}

variable "db_port" {
  type        = number
  description = "Database listening port"
  default     = 3306
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

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}
