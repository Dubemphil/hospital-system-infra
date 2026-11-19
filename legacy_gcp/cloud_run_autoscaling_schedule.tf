# ==============================================================================
# SOW Cost Optimization: Automated Scheduled Scaling for Clinic Surge Hours
# ==============================================================================

# Service Account for Cloud Scheduler to adjust Cloud Run min-instances
resource "google_service_account" "scaling_scheduler_sa" {
  account_id   = "sa-hhp-scaling-scheduler"
  display_name = "HHP Autoscaling Scheduler Service Account"
}

# Grant Cloud Run Admin permission to update service scaling limits
resource "google_project_iam_member" "scheduler_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.scaling_scheduler_sa.email}"
}

# ------------------------------------------------------------------------------
# 1. Morning Clinic Check-in Surge: 7:15 AM Pre-warm (min_instances = 2)
# ------------------------------------------------------------------------------
resource "google_cloud_scheduler_job" "scale_up_morning" {
  name        = "hhp-scale-up-morning-rush"
  description = "Pre-warms 2 instances before 7:30 AM morning check-in rush"
  schedule    = "15 7 * * 1-5" # 07:15 AM Mon-Fri
  time_zone   = "America/New_York"

  http_target {
    http_method = "PATCH"
    uri         = "https://${var.region}-run.googleapis.com/v2/projects/${var.project_id}/locations/${var.region}/services/${google_cloud_run_v2_service.api_service.name}?updateMask=template.scaling.minInstanceCount"
    body = base64encode(jsonencode({
      template = {
        scaling = {
          minInstanceCount = 2
        }
      }
    }))
    headers = {
      "Content-Type" = "application/json"
    }
    oauth_token {
      service_account_email = google_service_account.scaling_scheduler_sa.email
    }
  }
}

# ------------------------------------------------------------------------------
# 2. Morning Clinic Ramp-down: 9:45 AM Scale-to-zero (min_instances = 0)
# ------------------------------------------------------------------------------
resource "google_cloud_scheduler_job" "scale_down_morning" {
  name        = "hhp-scale-down-morning-rush"
  description = "Ramps down to zero idle instances after 9:30 AM morning rush"
  schedule    = "45 9 * * 1-5" # 09:45 AM Mon-Fri
  time_zone   = "America/New_York"

  http_target {
    http_method = "PATCH"
    uri         = "https://${var.region}-run.googleapis.com/v2/projects/${var.project_id}/locations/${var.region}/services/${google_cloud_run_v2_service.api_service.name}?updateMask=template.scaling.minInstanceCount"
    body = base64encode(jsonencode({
      template = {
        scaling = {
          minInstanceCount = 0
        }
      }
    }))
    headers = {
      "Content-Type" = "application/json"
    }
    oauth_token {
      service_account_email = google_service_account.scaling_scheduler_sa.email
    }
  }
}

# ------------------------------------------------------------------------------
# 3. Afternoon Clinic Rush: 2:45 PM Pre-warm (min_instances = 2)
# ------------------------------------------------------------------------------
resource "google_cloud_scheduler_job" "scale_up_afternoon" {
  name        = "hhp-scale-up-afternoon-rush"
  description = "Pre-warms 2 instances before 3:00 PM afternoon clinic rush"
  schedule    = "45 14 * * 1-5" # 02:45 PM Mon-Fri
  time_zone   = "America/New_York"

  http_target {
    http_method = "PATCH"
    uri         = "https://${var.region}-run.googleapis.com/v2/projects/${var.project_id}/locations/${var.region}/services/${google_cloud_run_v2_service.api_service.name}?updateMask=template.scaling.minInstanceCount"
    body = base64encode(jsonencode({
      template = {
        scaling = {
          minInstanceCount = 2
        }
      }
    }))
    headers = {
      "Content-Type" = "application/json"
    }
    oauth_token {
      service_account_email = google_service_account.scaling_scheduler_sa.email
    }
  }
}

# ------------------------------------------------------------------------------
# 4. Evening Ramp-down & Overnight Idle: 5:45 PM (min_instances = 0)
# ------------------------------------------------------------------------------
resource "google_cloud_scheduler_job" "scale_down_evening" {
  name        = "hhp-scale-down-evening"
  description = "Scales to zero idle compute overnight ($0.00 spend)"
  schedule    = "45 17 * * 1-5" # 05:45 PM Mon-Fri
  time_zone   = "America/New_York"

  http_target {
    http_method = "PATCH"
    uri         = "https://${var.region}-run.googleapis.com/v2/projects/${var.project_id}/locations/${var.region}/services/${google_cloud_run_v2_service.api_service.name}?updateMask=template.scaling.minInstanceCount"
    body = base64encode(jsonencode({
      template = {
        scaling = {
          minInstanceCount = 0
        }
      }
    }))
    headers = {
      "Content-Type" = "application/json"
    }
    oauth_token {
      service_account_email = google_service_account.scaling_scheduler_sa.email
    }
  }
}
