# ==============================================================================
# Variables - Horizon Health Partners (HHP) Cloud Run Platform
# ==============================================================================

variable "project_id" {
  type        = string
  description = "GCP Project ID for Horizon Health Partners"
  default     = "festive-ally-443007-r4"
}

variable "region" {
  type        = string
  description = "Primary GCP Region"
  default     = "us-central1"
}

variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
  default     = "staging"
}

variable "vpc_name" {
  type        = string
  description = "VPC network name"
  default     = "hhp-prod-vpc"
}

variable "subnet_name" {
  type        = string
  description = "Subnet name for Cloud Run Direct VPC Egress"
  default     = "hhp-subnet-app"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for application subnet"
  default     = "10.10.1.0/24"
}

variable "domain_name" {
  type        = string
  description = "Root or main frontend domain name"
  default     = "devopsstandard.name.ng"
}

variable "api_subdomain" {
  type        = string
  description = "API domain name"
  default     = "api.devopsstandard.name.ng"
}

variable "app_image" {
  type        = string
  description = "Container image for Cloud Run backend"
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "db_tier" {
  type        = string
  description = "Cloud SQL MySQL tier (Cost-optimized: db-custom-2-7680 or db-f1-micro for dev)"
  default     = "db-custom-2-7680"
}

variable "db_name" {
  type        = string
  description = "Database name for the hospital application"
  default     = "dental_management_system"
}

variable "db_user" {
  type        = string
  description = "Database user for the hospital application"
  default     = "hospital_app_user"
}

variable "enable_cloud_armor" {
  type        = bool
  description = "Enable Cloud Armor edge WAF and OWASP security rules"
  default     = true
}

variable "audit_retention_days" {
  type        = number
  description = "Number of days to immutably retain audit and access logs for HIPAA compliance"
  default     = 365
}

variable "github_backend_repo" {
  type        = string
  description = "GitHub repository for backend (owner/repo) for Workload Identity trust"
  default     = "Dubemphil/Hospital_backend_app"
}

variable "github_frontend_repo" {
  type        = string
  description = "GitHub repository for frontend (owner/repo) for Workload Identity trust"
  default     = "Dubemphil/Hospital_frontend_app"
}
