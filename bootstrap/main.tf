# ==============================================================================
# Bootstrap Module - S3 Remote State, DynamoDB Locking & GitHub OIDC IAM Role
# One-time CLI Execution to Enable 100% Keyless Pipeline Automation
# ==============================================================================

data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# S3 Bucket for Terraform Remote State
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Name        = "${var.project_name}-tfstate"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# DynamoDB Table for Distributed State Locking
# ------------------------------------------------------------------------------
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-terraform-locks"
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# GitHub Actions OpenID Connect (OIDC) Identity Provider
# Enables keyless authentication from GitHub Actions into AWS
# ------------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f8d264fcd9"]

  tags = {
    Name = "${var.project_name}-github-oidc-provider"
  }
}

# ------------------------------------------------------------------------------
# IAM Role: Infrastructure CI/CD Pipeline (Terraform Plan & Apply)
# This role allows the pipeline to deploy the rest of the infrastructure keylessly!
# ------------------------------------------------------------------------------
resource "aws_iam_role" "infra_deployer" {
  name = "${var.project_name}-${var.environment}-infra-deployer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-infra-deployer-role"
    Environment = var.environment
  }
}

# PowerUser permissions to deploy VPC, RDS, ECS, CloudFront, S3, KMS
resource "aws_iam_role_policy_attachment" "infra_deployer_poweruser" {
  role       = aws_iam_role.infra_deployer.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# IAM permissions to manage application roles and policies
resource "aws_iam_role_policy" "infra_deployer_iam" {
  name = "${var.project_name}-${var.environment}-infra-iam-policy"
  role = aws_iam_role.infra_deployer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:*"
        ]
        Resource = "*"
      }
    ]
  })
}
