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
  description = "VPC ID where ECS and ALB resources are created"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for ECS Fargate tasks"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security Group ID for the Application Load Balancer"
}

variable "ecs_security_group_id" {
  type        = string
  description = "Security Group ID for the ECS Fargate tasks"
}

variable "container_image" {
  type        = string
  description = "Container image URI for backend task definition"
  default     = "public.ecr.aws/docker/library/httpd:alpine" # Lightweight bootstrap placeholder
}

variable "container_port" {
  type        = number
  description = "Port exposed by the backend container"
  default     = 8080
}

variable "task_cpu" {
  type        = number
  description = "Fargate CPU units (256, 512, 1024, 2048)"
  default     = 512
}

variable "task_memory" {
  type        = number
  description = "Fargate Memory limit in MiB (512, 1024, 2048, 4096)"
  default     = 1024
}

variable "desired_count" {
  type        = number
  description = "Desired number of running ECS Fargate tasks"
  default     = 2
}

variable "db_endpoint" {
  type        = string
  description = "RDS MySQL endpoint address"
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

variable "db_secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret storing DB credentials"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS CMK ARN for decrypting secrets and CloudWatch logs"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}
