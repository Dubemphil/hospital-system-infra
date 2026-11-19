# ==============================================================================
# Bootstrap Variables
# ==============================================================================

variable "aws_region" {
  type        = string
  description = "Target AWS Region for the remote state backend"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name prefix"
  default     = "hospital-system"
}
