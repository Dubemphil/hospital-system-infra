# ==============================================================================
# External Application Load Balancer & Serverless NEG Routing
# ==============================================================================

# Global Anycast Public IP Address
resource "google_compute_global_address" "lb_ip" {
  name = "hhp-lb-ip"
}

# Serverless Network Endpoint Group (NEG) pointing to Cloud Run backend
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "hhp-backend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = google_cloud_run_v2_service.api_service.name
  }
}

# Backend Service with Cloud Armor Edge Protection Attached
resource "google_compute_backend_service" "api_backend" {
  name                  = "hhp-backend-service"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = var.enable_cloud_armor ? google_compute_security_policy.edge_security[0].id : null

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

# Google-managed SSL Certificate
resource "google_compute_managed_ssl_certificate" "api_ssl" {
  name = "hhp-ssl-cert"

  managed {
    domains = [var.domain_name, var.api_subdomain]
  }
}

# URL Map: Route /api/* to Cloud Run, and /* to Cloud CDN Frontend
resource "google_compute_url_map" "https_url_map" {
  name            = "hhp-url-map"
  default_service = google_compute_backend_bucket.frontend_backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "hhp-paths"
  }

  path_matcher {
    name            = "hhp-paths"
    default_service = google_compute_backend_bucket.frontend_backend.id

    path_rule {
      paths   = ["/api/*", "/v2/api-docs", "/swagger-ui.html", "/webjars/*", "/swagger-resources/*"]
      service = google_compute_backend_service.api_backend.id
    }
  }
}

# Target HTTPS Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "hhp-https-proxy"
  url_map          = google_compute_url_map.https_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.api_ssl.id]
}

# Global Forwarding Rule (Port 443)
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name                  = "hhp-https-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.https_proxy.id
  ip_address            = google_compute_global_address.lb_ip.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# ------------------------------------------------------------------------------
# HTTP (Port 80) to HTTPS (Port 443) Automatic Redirect
# ------------------------------------------------------------------------------
resource "google_compute_url_map" "http_redirect_map" {
  name = "hhp-http-redirect-map"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "hhp-http-proxy"
  url_map = google_compute_url_map.http_redirect_map.id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name                  = "hhp-http-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http_proxy.id
  ip_address            = google_compute_global_address.lb_ip.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
