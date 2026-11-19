output "state_bucket_name" {
  description = "Name of the S3 bucket created for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table created for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC Identity Provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_oidc_infra_role_arn" {
  description = "IAM Role ARN to paste into GitHub Secrets as AWS_ROLE_ARN for hospital-system-infra"
  value       = aws_iam_role.infra_deployer.arn
}

output "backend_config_instruction" {
  description = "Backend configuration block to paste into terraform/backend.tf"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "dev/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
        encrypt        = true
      }
    }
  EOT
}
