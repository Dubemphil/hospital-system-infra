# ==============================================================================
# Terraform Core Configuration & Providers - Hospital Cloud Run (HHP)
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.15.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }

  # Remote backend configured dynamically via -backend-config or local for staging
  # backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
