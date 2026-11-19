# ==============================================================================
# Outputs - Dev Environment (Hospital System)
# ==============================================================================

# ------------------------------------------------------------------------------
# Custom Domain & SSL/TLS
# ------------------------------------------------------------------------------
output "custom_frontend_url" {
  description = "URL for the React Frontend Portal"
  value       = var.enable_custom_domain ? "https://${var.domain_name}" : "https://${module.frontend.cloudfront_domain_name}"
}

output "custom_backend_api_url" {
  description = "URL for the Spring Boot Backend API"
  value       = var.enable_custom_domain ? "https://${var.api_subdomain}" : "http://${module.ecs.alb_dns_name}"
}

output "acm_certificate_arn" {
  description = "ARN of the public ACM TLS certificate"
  value       = var.enable_custom_domain ? module.acm[0].certificate_arn : null
}

output "dns_validation_records" {
  description = "CNAME records required for DNS validation if your domain is managed outside Route 53"
  value       = var.enable_custom_domain ? module.acm[0].dns_validation_records : null
}

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

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution for cache invalidation"
  value       = module.frontend.cloudfront_distribution_id
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

output "github_oidc_backend_role_arn" {
  description = "IAM Role ARN for Backend GitHub Actions CI/CD pipeline"
  value       = module.oidc.backend_deployer_role_arn
}

output "github_oidc_frontend_role_arn" {
  description = "IAM Role ARN for Frontend GitHub Actions CI/CD pipeline"
  value       = module.oidc.frontend_deployer_role_arn
}
