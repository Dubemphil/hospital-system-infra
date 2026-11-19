# ==============================================================================
# SOW Contract Safety: Schema Registry for OpenAPI Diff in CI/CD
# ==============================================================================

# GCS Bucket storing immutable, versioned OpenAPI contracts for CI verification
resource "google_storage_bucket" "contract_registry" {
  name                        = "${var.project_id}-contract-registry"
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = {
    purpose    = "contract_testing"
    managed_by = "terraform"
  }
}
