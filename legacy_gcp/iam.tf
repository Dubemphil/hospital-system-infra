# ==============================================================================
# Horizon Health Partners - Direct Workload Identity Federation (No SA Keys/Emails)
# ==============================================================================

# Fetch current GCP project data
data "google_project" "current" {
  project_id = var.project_id
}

locals {
  pool_name          = "projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/hhp-github-pool"
  backend_principal  = "principalSet://iam.googleapis.com/${local.pool_name}/attribute.repository/${var.github_backend_repo}"
  frontend_principal = "principalSet://iam.googleapis.com/${local.pool_name}/attribute.repository/${var.github_frontend_repo}"
}

# ------------------------------------------------------------------------------
# Direct IAM Role Grants to GitHub Backend Repository via WIF
# ------------------------------------------------------------------------------

# 1. Cloud Run Developer (Allows deploying revisions)
resource "google_project_iam_member" "wif_backend_run_dev" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = local.backend_principal
}

# 2. Service Account User on cloud_run_sa (Allows attaching the runtime SA to Cloud Run)
resource "google_service_account_iam_member" "wif_backend_act_as" {
  service_account_id = google_service_account.cloud_run_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = local.backend_principal
}

# 3. Artifact Registry Writer (Allows pushing container images)
resource "google_artifact_registry_repository_iam_member" "wif_backend_artifact_writer" {
  location   = var.region
  repository = google_artifact_registry_repository.app_repo.name
  role       = "roles/artifactregistry.writer"
  member     = local.backend_principal
}

# 4. GCS Contract Registry Access (For OpenAPI schema publishing)
resource "google_storage_bucket_iam_member" "wif_backend_contract_sync" {
  bucket = google_storage_bucket.contract_registry.name
  role   = "roles/storage.objectAdmin"
  member = local.backend_principal
}

# ------------------------------------------------------------------------------
# Direct IAM Role Grants to GitHub Frontend Repository via WIF
# ------------------------------------------------------------------------------

# 1. GCS Frontend Storage Object Admin (Allows static asset upload & delete)
resource "google_storage_bucket_iam_member" "wif_frontend_storage" {
  bucket = google_storage_bucket.frontend.name
  role   = "roles/storage.objectAdmin"
  member = local.frontend_principal
}
