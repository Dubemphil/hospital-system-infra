# ==============================================================================
# Outputs - Hospital System AWS Infrastructure
# ==============================================================================

# ------------------------------------------------------------------------------
# Networking
# ------------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the custom 3-tier VPC"
  value       = module.vpc.vpc_id
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.vpc.nat_gateway_ip
}

# ------------------------------------------------------------------------------
# Frontend & CDN
# ------------------------------------------------------------------------------
output "frontend_cdn_domain" {
  description = "The CloudFront CDN domain name serving the frontend and /api"
  value       = module.frontend.cloudfront_domain_name
}

output "frontend_s3_bucket" {
  description = "S3 bucket name where static React assets are deployed"
  value       = module.frontend.s3_bucket_id
}

# ------------------------------------------------------------------------------
# Compute & Load Balancing
# ------------------------------------------------------------------------------
output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.ecs.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster running backend Fargate tasks"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service running backend tasks"
  value       = module.ecs.service_name
}

# ------------------------------------------------------------------------------
# Container Registry (ECR)
# ------------------------------------------------------------------------------
output "ecr_repository_url" {
  description = "URL of the Amazon ECR repository for Docker images"
  value       = module.ecr.repository_url
}

# ------------------------------------------------------------------------------
# Database
# ------------------------------------------------------------------------------
output "rds_endpoint" {
  description = "Connection endpoint of the RDS MySQL database"
  value       = module.rds.db_instance_endpoint
}

output "rds_address" {
  description = "Hostname of the RDS MySQL database"
  value       = module.rds.db_instance_address
}

# ------------------------------------------------------------------------------
# Security & CI/CD OIDC Roles
# ------------------------------------------------------------------------------
output "kms_key_arn" {
  description = "ARN of the Customer Managed KMS Key (CMK)"
  value       = module.security.kms_key_arn
}

output "db_credentials_secret_name" {
  description = "Name of the Secrets Manager secret storing database credentials"
  value       = module.security.db_secret_name
}

output "github_oidc_infra_role_arn" {
  description = "IAM Role ARN for Terraform Infrastructure GitHub Actions CI/CD pipeline"
  value       = module.oidc.infra_deployer_role_arn
}

output "github_oidc_backend_role_arn" {
  description = "IAM Role ARN for Backend GitHub Actions CI/CD pipeline"
  value       = module.oidc.backend_deployer_role_arn
}

output "github_oidc_frontend_role_arn" {
  description = "IAM Role ARN for Frontend GitHub Actions CI/CD pipeline"
  value       = module.oidc.frontend_deployer_role_arn
}
