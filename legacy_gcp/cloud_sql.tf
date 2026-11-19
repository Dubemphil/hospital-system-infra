# ==============================================================================
# Google Cloud SQL: MySQL Instance for Hospital Management System
# Private IP only (Zero Public Exposure - HIPAA & PHI Compliant)
# ==============================================================================

resource "random_password" "db_password" {
  length  = 24
  special = false
}

resource "google_sql_database_instance" "mysql" {
  name                = "hhp-mysql-${var.environment}"
  database_version    = "MYSQL_8_0"
  region              = var.region
  deletion_protection = false

  settings {
    tier              = var.db_tier
    availability_type = "ZONAL" # Cost-effective single zone; can switch to REGIONAL for HA prod
    disk_type         = "PD_SSD"
    disk_size         = 20
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = false # Zero public IP - strictly private
      private_network = google_compute_network.custom_vpc.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled                        = true
      binary_log_enabled             = true # Enables point-in-time recovery for PHI audits
      start_time                     = "03:00"
      transaction_log_retention_days = 7
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 4 # 4 AM UTC
      update_track = "stable"
    }

    database_flags {
      name  = "sql_mode"
      value = "TRADITIONAL"
    }
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

# Hospital Application Database
resource "google_sql_database" "app_db" {
  name      = var.db_name
  instance  = google_sql_database_instance.mysql.name
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

# Application Database User
resource "google_sql_user" "db_user" {
  name     = var.db_user
  instance = google_sql_database_instance.mysql.name
  password = random_password.db_password.result
}
