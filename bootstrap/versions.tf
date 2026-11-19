# ==============================================================================
# Bootstrap Versions - Terraform & Provider Configuration
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project    = var.project_name
      ManagedBy  = "Terraform-Bootstrap"
      Purpose    = "Terraform-Remote-State-Backend"
      Compliance = "HIPAA-Auditable"
    }
  }
}

