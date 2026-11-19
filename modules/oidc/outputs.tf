output "oidc_provider_arn" {
  description = "The ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "backend_deployer_role_arn" {
  description = "The ARN of the IAM role for Backend GitHub Actions"
  value       = aws_iam_role.backend_deployer.arn
}

output "frontend_deployer_role_arn" {
  description = "The ARN of the IAM role for Frontend GitHub Actions"
  value       = aws_iam_role.frontend_deployer.arn
}

