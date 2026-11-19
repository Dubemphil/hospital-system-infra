# ==============================================================================
# Bootstrap Module - S3 Remote State Bucket & DynamoDB Lock Table
# Production Foundation for Team CI/CD & State Integrity
# ==============================================================================

data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# S3 Bucket for Terraform Remote State
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"
  force_destroy = false # Prevent accidental deletion of state in production

  lifecycle {
    prevent_destroy = false # Set to true in permanent enterprise prod
  }

  tags = {
    Name = "${var.project_name}-tfstate"
  }
}

# Versioning: Allows state history recovery and rollback if state gets corrupted
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption: Protect sensitive state data at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public Access Block: 100% private state storage
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# DynamoDB Table for Distributed State Locking
# Prevents concurrent applies from corrupting the state file
# ------------------------------------------------------------------------------
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST" # Zero idle cost; pay only per lock request
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-terraform-locks"
  }
}
