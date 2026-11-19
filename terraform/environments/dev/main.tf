# ==============================================================================
# Dev Environment - Hospital Management System (AWS Infrastructure)
# Modular Architecture | Cost-Optimized | Isolated S3 Remote State
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Security Foundation (KMS, Security Groups, Secrets Manager)
# ------------------------------------------------------------------------------
module "security" {
  source = "../../modules/security"

  environment    = var.environment
  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  container_port = var.backend_container_port
  db_name        = var.db_name
  db_username    = var.db_username
}

# ------------------------------------------------------------------------------
# 2. 3-Tier Enterprise Networking (VPC, Subnets, NAT GW, Flow Logs)
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  kms_key_arn        = module.security.kms_key_arn
}

# ------------------------------------------------------------------------------
# 3. Relational Database Tier (Amazon RDS MySQL 8.0)
# ------------------------------------------------------------------------------
module "rds" {
  source = "../../modules/rds"

  environment           = var.environment
  project_name          = var.project_name
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = module.security.db_password
  db_instance_class     = var.db_instance_class
  multi_az              = var.db_multi_az
  backup_retention_days = var.db_backup_retention_days
  skip_final_snapshot   = var.db_skip_final_snapshot
  subnet_ids            = module.vpc.isolated_db_subnet_ids
  security_group_id     = module.security.rds_security_group_id
  kms_key_arn           = module.security.kms_key_arn
}

# ------------------------------------------------------------------------------
# 4. Container Registry (Amazon ECR)
# ------------------------------------------------------------------------------
module "ecr" {
  source = "../../modules/ecr"

  environment  = var.environment
  project_name = var.project_name
  kms_key_arn  = module.security.kms_key_arn
}

# ------------------------------------------------------------------------------
# 5. Compute Tier (AWS ECS Fargate Cluster, Task Definition, Service, ALB)
# ------------------------------------------------------------------------------
module "ecs" {
  source = "../../modules/ecs"

  environment           = var.environment
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_app_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  ecs_security_group_id = module.security.ecs_security_group_id
  container_image       = module.ecr.repository_url
  container_port        = var.backend_container_port
  task_cpu              = var.ecs_task_cpu
  task_memory           = var.ecs_task_memory
  desired_count         = var.ecs_desired_count
  db_endpoint           = module.rds.db_instance_address
  db_name               = var.db_name
  db_username           = var.db_username
  db_secret_arn         = module.security.db_secret_arn
  kms_key_arn           = module.security.kms_key_arn
  acm_certificate_arn   = var.enable_custom_domain ? module.acm[0].certificate_arn : null
}

# ------------------------------------------------------------------------------
# 6. Frontend Web Tier (Amazon S3 + CloudFront CDN + OAC)
# ------------------------------------------------------------------------------
module "frontend" {
  source = "../../modules/frontend"

  environment         = var.environment
  project_name        = var.project_name
  alb_dns_name        = module.ecs.alb_dns_name
  kms_key_arn         = module.security.kms_key_arn
  domain_name         = var.enable_custom_domain ? var.domain_name : null
  acm_certificate_arn = var.enable_custom_domain ? module.acm[0].certificate_arn : null
}

# ------------------------------------------------------------------------------
# 7. SSL/TLS Certificate & Custom Domains (ACM & Route 53)
# ------------------------------------------------------------------------------
module "acm" {
  count  = var.enable_custom_domain ? 1 : 0
  source = "../../modules/acm"

  environment            = var.environment
  project_name           = var.project_name
  domain_name            = var.domain_name
  api_subdomain          = var.api_subdomain
  manage_route53         = var.manage_route53
  cloudfront_domain_name = module.frontend.cloudfront_domain_name
  alb_dns_name           = module.ecs.alb_dns_name
  alb_zone_id            = module.ecs.alb_zone_id
}

# ------------------------------------------------------------------------------
# 8. CI/CD Identity Federation (GitHub Actions OIDC Least-Privilege Roles)
# ------------------------------------------------------------------------------
module "oidc" {
  source = "../../modules/oidc"

  environment                 = var.environment
  project_name                = var.project_name
  github_org                  = var.github_org
  github_backend_repo         = var.github_backend_repo
  github_frontend_repo        = var.github_frontend_repo
  github_infra_repo           = var.github_infra_repo
  ecr_repository_arn          = module.ecr.repository_arn
  ecs_cluster_arn             = module.ecs.cluster_id
  ecs_service_arn             = module.ecs.service_id
  ecs_execution_role_arn      = module.ecs.execution_role_arn
  ecs_task_role_arn           = module.ecs.task_role_arn
  frontend_bucket_arn         = module.frontend.s3_bucket_arn
  cloudfront_distribution_arn = module.frontend.cloudfront_distribution_arn
}
