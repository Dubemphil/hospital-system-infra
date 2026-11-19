# ==============================================================================
# Variables - Production Environment (Hospital System)
# ==============================================================================

variable "aws_region" {
  type        = string
  description = "Target AWS Region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Target deployment environment"
  default     = "prod"
}

variable "project_name" {
  type        = string
  description = "Project name prefix used for all infrastructure resources"
  default     = "hospital-system"
}

# ------------------------------------------------------------------------------
# Custom Domain & SSL/TLS Variables
# ------------------------------------------------------------------------------
variable "enable_custom_domain" {
  type        = bool
  description = "Whether to provision ACM certificate and configure custom domain aliases"
  default     = true
}

variable "domain_name" {
  type        = string
  description = "Frontend custom domain name"
  default     = "devopsstandard.name.ng"
}

variable "api_subdomain" {
  type        = string
  description = "Backend API custom subdomain name"
  default     = "api.devopsstandard.name.ng"
}

variable "manage_route53" {
  type        = bool
  description = "Set to true if Route 53 manages the hosted zone and should auto-create DNS records"
  default     = false
}

# ------------------------------------------------------------------------------
# Networking Variables
# ------------------------------------------------------------------------------
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the custom VPC (Isolated from dev)"
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for multi-AZ high availability"
  default     = ["us-east-1a", "us-east-1b"]
}

# ------------------------------------------------------------------------------
# Database Variables
# ------------------------------------------------------------------------------
variable "db_name" {
  type        = string
  description = "MySQL database name"
  default     = "dental_management_system"
}

variable "db_username" {
  type        = string
  description = "MySQL master username"
  default     = "hospital_app_admin"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class (Production Sizing)"
  default     = "db.t4g.small"
}

variable "db_multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment for database high availability"
  default     = true
}

variable "db_backup_retention_days" {
  type        = number
  description = "Retention period for automated backups (days) - HIPAA Compliant"
  default     = 7
}

variable "db_skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot when destroying database (False for Production)"
  default     = false
}

# ------------------------------------------------------------------------------
# Container & ECS Variables
# ------------------------------------------------------------------------------
variable "backend_container_port" {
  type        = number
  description = "Port exposed by the Spring Boot backend container"
  default     = 8080
}

variable "ecs_task_cpu" {
  type        = number
  description = "CPU units allocated to ECS Fargate backend task (256, 512, 1024, 2048)"
  default     = 512
}

variable "ecs_task_memory" {
  type        = number
  description = "Memory (in MiB) allocated to ECS Fargate backend task"
  default     = 1024
}

variable "ecs_desired_count" {
  type        = number
  description = "Number of running backend tasks in the ECS service (High Availability)"
  default     = 2
}

# ------------------------------------------------------------------------------
# GitHub OIDC Variables
# ------------------------------------------------------------------------------
variable "github_org" {
  type        = string
  description = "GitHub organization or user account owning the repositories"
  default     = "Dubemphil"
}

variable "github_backend_repo" {
  type        = string
  description = "Repository name for the Spring Boot backend"
  default     = "hospital-system-backend"
}

variable "github_frontend_repo" {
  type        = string
  description = "Repository name for the React frontend"
  default     = "hospital-system-frontend"
}

variable "github_infra_repo" {
  type        = string
  description = "Repository name for the Terraform infrastructure"
  default     = "hospital-system-infra"
}

