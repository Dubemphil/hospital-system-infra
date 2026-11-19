# ==============================================================================
# S3 Remote State Backend - Production Environment
# ==============================================================================

terraform {
  backend "s3" {
    bucket         = "hospital-system-tfstate-323198192259"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hospital-system-terraform-locks"
    encrypt        = true
  }
}
