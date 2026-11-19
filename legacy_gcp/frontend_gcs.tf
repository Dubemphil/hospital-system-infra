# ==============================================================================
# Horizon Health Partners - Static Frontend Hosting (GCS + Cloud CDN)
# ==============================================================================

# GCS Bucket storing compiled React Single Page Application (build/ directory)
resource "google_storage_bucket" "frontend" {
  name                        = "${var.project_id}-hospital-frontend"
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html" # Supports client-side React Router navigation
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  labels = {
    app        = "hospital-management"
    component  = "frontend"
    managed_by = "terraform"
  }
}

# Public read access for static assets through CDN
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.frontend.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Backend Bucket with Cloud CDN Enabled (Edge Caching for Instant Global Delivery)
resource "google_compute_backend_bucket" "frontend_backend" {
  name        = "hhp-frontend-cdn-backend"
  bucket_name = google_storage_bucket.frontend.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 3600
    max_ttl           = 86400
    client_ttl        = 3600
    negative_caching  = true
    serve_while_stale = 86400
  }
}
