# ==============================================================================
# Google Cloud Run v2: Hospital Backend REST API with Direct VPC Egress
# ==============================================================================

# Runtime Service Account for Cloud Run API
resource "google_service_account" "cloud_run_sa" {
  account_id   = "sa-hhp-backend-runtime"
  display_name = "Horizon Health Partners Backend Runtime Service Account"
}

# Secret Manager for Database Password
resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "hhp-db-password-${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = random_password.db_password.result
}

resource "google_secret_manager_secret_iam_member" "cloud_run_secret_access" {
  secret_id = google_secret_manager_secret.db_password_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# ------------------------------------------------------------------------------
# Cloud Run Service (Direct VPC Egress to Private Cloud SQL)
# ------------------------------------------------------------------------------
resource "google_cloud_run_v2_service" "api_service" {
  name                = "hhp-backend"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" # Only accessible via HTTPS Load Balancer
  deletion_protection = false

  template {
    service_account = google_service_account.cloud_run_sa.email

    scaling {
      min_instance_count = 0 # Scale to 0 at night ($0.00 idle compute spend)
      max_instance_count = 8 # Budget ceiling
    }

    max_instance_request_concurrency = 80

    # Direct VPC Egress: Private routing directly to Cloud SQL with ZERO connector VMs
    vpc_access {
      network_interfaces {
        network    = google_compute_network.custom_vpc.name
        subnetwork = google_compute_subnetwork.app_subnet.name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.app_image

      resources {
        limits = {
          cpu    = "1000m" # 1 vCPU
          memory = "1Gi"   # 1 GiB RAM (JVM heap optimized)
        }
        cpu_idle = true # CPU billed ONLY when serving requests
      }

      ports {
        container_port = 8080
      }

      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = "prod"
      }
      env {
        name  = "DB_URL"
        value = "jdbc:mysql://${google_sql_database_instance.mysql.private_ip_address}:3306/${google_sql_database.app_db.name}?createDatabaseIfNotExist=true&useUnicode=true&useSSL=false&allowPublicKeyRetrieval=true"
      }
      env {
        name  = "DB_USER"
        value = var.db_user
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password_secret.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "UPLOAD_BASE_PATH"
        value = "/tmp/uploads"
      }
      env {
        name  = "CORS_ALLOWED_ORIGINS"
        value = "https://${var.domain_name},https://${var.api_subdomain}"
      }

      startup_probe {
        http_get {
          path = "/api/patient/bloodgroup/all"
          port = 8080
        }
        initial_delay_seconds = 15
        period_seconds        = 10
        failure_threshold     = 6
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [
    google_secret_manager_secret_iam_member.cloud_run_secret_access,
    google_secret_manager_secret_version.db_password_version,
    google_compute_subnetwork.app_subnet,
    google_sql_database_instance.mysql
  ]
}

# Allow Load Balancer / Serverless NEG to invoke the Cloud Run Service
resource "google_cloud_run_service_iam_member" "lb_invoker" {
  location = var.region
  service  = google_cloud_run_v2_service.api_service.name
  role     = "roles/run.invoker"
  member   = "allUsers" # Protected by Cloud Armor WAF and Load Balancer path routing
}
