# ==============================================================================
# Production Environment Variables: terraform.tfvars
# Target: AWS Production Deployment (High Availability / Multi-AZ / Custom Domain)
# ==============================================================================

aws_region   = "us-east-1"
environment  = "prod"
project_name = "hospital-system"

# Custom Domain & SSL/TLS Configuration
enable_custom_domain = true
domain_name          = "devopsstandard.name.ng"
api_subdomain        = "api.devopsstandard.name.ng"
manage_route53       = false

# Networking (Isolated Production VPC CIDR)
vpc_cidr           = "10.1.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Database Configuration (Production High Availability)
db_name                  = "dental_management_system"
db_username              = "hospital_app_admin"
db_instance_class        = "db.t4g.small"
db_multi_az              = true
db_backup_retention_days = 7
db_skip_final_snapshot   = false

# ECS Fargate Sizing (High Availability across 2 AZs)
backend_container_port = 8080
ecs_task_cpu           = 512
ecs_task_memory        = 1024
ecs_desired_count      = 2

# GitHub Actions OIDC Integration
github_org           = "Dubemphil"
github_backend_repo  = "hospital-system-backend"
github_frontend_repo = "hospital-system-frontend"
github_infra_repo    = "hospital-system-infra"
