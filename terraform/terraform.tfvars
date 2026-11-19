# ==============================================================================
# Development Environment Variables: terraform.tfvars
# Target: AWS dev deployment
# ==============================================================================

aws_region   = "us-east-1"
environment  = "dev"
project_name = "hospital-system"

# Custom Domain & SSL/TLS Configuration
# Set to false for the initial pipeline run so all base infrastructure (VPC, RDS, ECS, S3, CloudFront)
# creates cleanly without waiting for external DNS validation. Once deployed, set to true to issue ACM TLS cert.
enable_custom_domain = false
domain_name          = "devopsstandard.name.ng"
api_subdomain        = "api.devopsstandard.name.ng"
manage_route53       = false # Set to true if Route 53 manages the hosted zone

# Networking
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Database Configuration (Optimized for Dev / Cost-effective)
db_name                  = "dental_management_system"
db_username              = "hospital_app_user"
db_instance_class        = "db.t4g.micro"
db_multi_az              = false
db_backup_retention_days = 1
db_skip_final_snapshot   = true

# ECS Fargate Sizing (Cost-effective for Dev)
backend_container_port = 8080
ecs_task_cpu           = 512  # 0.5 vCPU
ecs_task_memory        = 1024 # 1024 MiB
ecs_desired_count      = 1    # 1 task for dev environment

# GitHub Actions OIDC Integration
github_org           = "Dubemphil"
github_backend_repo  = "hospital-system-backend"
github_frontend_repo = "hospital-system-frontend"
github_infra_repo    = "hospital_terraform"

