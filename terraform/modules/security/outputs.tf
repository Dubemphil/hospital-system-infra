output "kms_key_arn" {
  description = "ARN of the KMS CMK"
  value       = aws_kms_key.main.arn
}

output "kms_key_id" {
  description = "ID of the KMS CMK"
  value       = aws_kms_key.main.key_id
}

output "alb_security_group_id" {
  description = "ID of the Application Load Balancer security group"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ID of the ECS Fargate tasks security group"
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "ID of the RDS database security group"
  value       = aws_security_group.rds.id
}

output "db_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret storing DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_secret_name" {
  description = "Name of the AWS Secrets Manager secret storing DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "db_password" {
  description = "Generated master database password"
  value       = random_password.db_password.result
  sensitive   = true
}

