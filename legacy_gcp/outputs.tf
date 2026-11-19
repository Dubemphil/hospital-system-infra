# ==============================================================================
# Terraform Outputs - Horizon Health Partners Infrastructure
# ==============================================================================

output "load_balancer_ip" {
  description = "Static Global IPv4 Anycast address for the Load Balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "primary_domain" {
  description = "Frontend domain"
  value       = var.domain_name
}

output "api_subdomain" {
  description = "API domain"
  value       = var.api_subdomain
}

output "cloud_run_service_name" {
  description = "Cloud Run backend service name"
  value       = google_cloud_run_v2_service.api_service.name
}

output "cloud_run_service_url" {
  description = "Direct URI for Cloud Run backend"
  value       = google_cloud_run_v2_service.api_service.uri
}

output "frontend_gcs_bucket" {
  description = "GCS bucket hosting the static React frontend SPA"
  value       = google_storage_bucket.frontend.name
}

output "contract_registry_bucket" {
  description = "GCS bucket storing OpenAPI contracts for CI breaking-change verification"
  value       = google_storage_bucket.contract_registry.name
}

output "hipaa_audit_logs_bucket" {
  description = "Encrypted GCS bucket with 365-day immutable retention for HIPAA audit trails"
  value       = google_storage_bucket.audit_logs.name
}

output "cloud_sql_instance_name" {
  description = "Cloud SQL MySQL instance name"
  value       = google_sql_database_instance.mysql.name
}

output "cloud_sql_private_ip" {
  description = "Private IP address for Cloud SQL MySQL"
  value       = google_sql_database_instance.mysql.private_ip_address
}

output "artifact_registry_repository" {
  description = "Artifact Registry Docker repository path"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_repo.name}"
}

output "wif_provider_name" {
  description = "Workload Identity Federation Provider resource name for GitHub Actions secret"
  value       = "${local.pool_name}/providers/github-provider"
}

output "dns_records_to_create" {
  description = "DNS records to configure at your domain DNS registrar"
  value = {
    frontend = {
      name  = var.domain_name
      type  = "A"
      value = google_compute_global_address.lb_ip.address
      ttl   = 300
    }
    api = {
      name  = var.api_subdomain
      type  = "A"
      value = google_compute_global_address.lb_ip.address
      ttl   = 300
    }
  }
}
