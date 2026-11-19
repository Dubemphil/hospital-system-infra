# ==============================================================================
# RDS Module - Amazon RDS MySQL 8.0 (HIPAA Compliant)
# Multi-AZ capable, KMS Encrypted, Private Isolated Subnets Only
# ==============================================================================

resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-${var.environment}-db-subnet-group"
  description = "Database Subnet Group for isolated private subnets"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

resource "aws_db_parameter_group" "mysql" {
  name        = "${var.project_name}-${var.environment}-mysql80-params"
  family      = "mysql8.0"
  description = "Custom parameters for MySQL 8.0 HIPAA compliance"

  # Enforce TLS 1.2+ for HIPAA in-transit compliance
  parameter {
    name  = "require_secure_transport"
    value = "ON"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = var.tags
}

resource "aws_db_instance" "main" {
  identifier            = "${var.project_name}-${var.environment}-mysql"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = var.db_instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]
  parameter_group_name   = aws_db_parameter_group.mysql.name

  multi_az            = var.multi_az
  publicly_accessible = false

  backup_retention_period     = var.backup_retention_days
  backup_window               = "03:00-04:00"
  maintenance_window          = "Sun:04:30-Sun:05:30"
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.project_name}-${var.environment}-mysql-final-snapshot"
  deletion_protection       = var.deletion_protection

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-mysql"
    Tier = "Isolated-DB"
  })
}
