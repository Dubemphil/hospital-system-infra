# ==============================================================================
# Security Module - KMS CMK, Secrets Manager, and Least-Privilege SGs
# HIPAA Compliant Encryption-at-Rest & Strict Tier Isolation
# ==============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ------------------------------------------------------------------------------
# Customer Managed Key (CMK) - HIPAA Compliance Requirement
# ------------------------------------------------------------------------------
resource "aws_kms_key" "main" {
  description             = "KMS CMK for ${var.project_name}-${var.environment} (HIPAA Compliance)"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs to use the key"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-kms"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-kms"
  target_key_id = aws_kms_key.main.key_id
}

# ------------------------------------------------------------------------------
# Security Groups: Tier 1 - Application Load Balancer
# ------------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Controls inbound traffic to the public Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
    Tier = "Public-ALB"
  })
}

# ------------------------------------------------------------------------------
# Security Groups: Tier 2 - ECS Fargate Backend Tasks
# ------------------------------------------------------------------------------
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Controls traffic to ECS Fargate backend tasks (Strictly from ALB)"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow inbound HTTP only from ALB security group"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic (via NAT Gateway for outbound API/package calls)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecs-sg"
    Tier = "Private-App"
  })
}

# ------------------------------------------------------------------------------
# Security Groups: Tier 3 - RDS MySQL Database
# ------------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Controls traffic to RDS MySQL database (Strictly from ECS tasks)"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL ingress strictly from ECS Fargate tasks"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "No outbound traffic needed from database"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["127.0.0.1/32"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-rds-sg"
    Tier = "Isolated-DB"
  })
}

# ------------------------------------------------------------------------------
# Secrets Manager: Database Credentials
# ------------------------------------------------------------------------------
resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}-${var.environment}-db-credentials"
  description             = "Master credentials for RDS MySQL database"
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 0 # Immediate deletion upon terraform destroy during testing

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    engine   = "mysql"
    host     = "" # Populated by outputs / application injection
    port     = var.db_port
    database = var.db_name
    username = var.db_username
    password = random_password.db_password.result
  })
}

