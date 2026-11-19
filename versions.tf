# ==============================================================================
# Terraform & Provider Versions - Enterprise AWS Infrastructure
# Horizon Health Partners / Hospital Management System
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Production note: In multi-engineer teams, configure an S3 backend here:
  # backend "s3" {
  #   bucket         = "hospital-system-terraform-state-prod"
  #   key            = "environments/production/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "hospital-system-terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Compliance  = "HIPAA-Auditable"
      Owner       = "Platform-Engineering"
    }
  }
}
