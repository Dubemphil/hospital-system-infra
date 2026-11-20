# ==============================================================================
# OIDC Module - Application GitHub Actions IAM Roles
# Backend (ECR/ECS) and Frontend (S3/CloudFront) Keyless STS Federation
# ==============================================================================

data "aws_caller_identity" "current" {}

locals {
  github_oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

# ------------------------------------------------------------------------------
# IAM Role: Backend CI/CD Pipeline (ECR Push & ECS Deploy)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "backend_deployer" {
  name = "${var.project_name}-${var.environment}-backend-deployer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.github_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_org}/${var.github_backend_repo}:*",
              "repo:${lower(var.github_org)}/${var.github_backend_repo}:*",
              "repo:*${var.github_backend_repo}*",
              "repo:*hospital-system-backend*",
              "repo:*hospital_backend*"
            ]
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "backend_deployer" {
  name = "${var.project_name}-${var.environment}-backend-deployer-policy"
  role = aws_iam_role.backend_deployer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuth"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = var.ecr_repository_arn
      },
      {
        Sid    = "ECSDeploy"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = var.ecs_service_arn
      },
      {
        Sid    = "ECSTaskDef"
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMPassRoleToECS"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          var.ecs_execution_role_arn,
          var.ecs_task_role_arn
        ]
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# IAM Role: Frontend CI/CD Pipeline (S3 Sync & CloudFront Invalidate)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "frontend_deployer" {
  name = "${var.project_name}-${var.environment}-frontend-deployer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.github_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_org}/${var.github_frontend_repo}:*",
              "repo:${lower(var.github_org)}/${var.github_frontend_repo}:*",
              "repo:*${var.github_frontend_repo}*",
              "repo:*hospital-system-frontend*",
              "repo:*hospital_frontend*"
            ]
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "frontend_deployer" {
  name = "${var.project_name}-${var.environment}-frontend-deployer-policy"
  role = aws_iam_role.frontend_deployer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3FrontendDeploy"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.frontend_bucket_arn,
          "${var.frontend_bucket_arn}/*"
        ]
      },
      {
        Sid    = "CloudFrontInvalidate"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation"
        ]
        Resource = var.cloudfront_distribution_arn
      }
    ]
  })
}
