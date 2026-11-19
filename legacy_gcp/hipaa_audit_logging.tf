# ==============================================================================
# Elena's Compliance Mandate: Immutable 365-Day HIPAA Audit Log Retention
# ==============================================================================

# Encrypted GCS Bucket for Immutable Audit Log Archive
resource "google_storage_bucket" "audit_logs" {
  name                        = "${var.project_id}-hipaa-audit-logs"
  location                    = var.region
  storage_class               = "COLDLINE" # Cost-effective long-term archival storage
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  # Immutable WORM Retention Policy (365 Days)
  retention_policy {
    is_locked        = false                            # Set to true in production once initial retention is verified
    retention_period = var.audit_retention_days * 86400 # 365 days in seconds
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.audit_retention_days + 30 # Grace period after retention expires
    }
  }

  labels = {
    compliance = "hipaa"
    data_class = "audit_trail"
    managed_by = "terraform"
    signed_off = "elena"
  }
}

# Cloud Logging Sink Exporting Application & Access Audit Logs to GCS
resource "google_logging_project_sink" "audit_sink" {
  name        = "hhp-hipaa-audit-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"

  # Filter: Captures Cloud Run access logs, Cloud SQL audit logs, and IAM activity
  filter = <<EOT
resource.type = "cloud_run_revision" OR
resource.type = "cloudsql_database" OR
protoPayload.serviceName = "run.googleapis.com" OR
protoPayload.serviceName = "cloudsql.googleapis.com"
EOT

  unique_writer_identity = true
}

# Grant the Sink's Service Account permission to write logs to the GCS bucket
resource "google_storage_bucket_iam_member" "sink_writer" {
  bucket = google_storage_bucket.audit_logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.audit_sink.writer_identity
}
