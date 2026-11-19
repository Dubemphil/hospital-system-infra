# ==============================================================================
# Google Artifact Registry with SOW Automated Cleanup Policies
# ==============================================================================

resource "google_artifact_registry_repository" "app_repo" {
  location      = var.region
  repository_id = "hospital-apps"
  description   = "Docker container repository for Horizon Health Partners"
  format        = "DOCKER"

  # SOW Cost Optimization: Prune old images to prevent image storage bloat
  cleanup_policies {
    id     = "keep-recent-5-versions"
    action = "KEEP"
    most_recent_versions {
      package_name_prefixes = ["hospital-backend"]
      keep_count            = 5
    }
  }

  cleanup_policies {
    id     = "delete-untagged-older-than-7-days"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "604800s" # 7 days
    }
  }
}
