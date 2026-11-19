# ==============================================================================
# Google Cloud Armor: Edge Security & HIPAA / PHI Endpoint Protection
# ==============================================================================

resource "google_compute_security_policy" "edge_security" {
  count       = var.enable_cloud_armor ? 1 : 0
  name        = "hhp-armor-edge-sec"
  description = "Edge WAF, rate limiting, and OWASP inspection for Horizon Health Partners"

  # ----------------------------------------------------------------------------
  # Rule 1: Brute Force Protection on Login & Patient Auth Endpoints (Priority 1000)
  # ----------------------------------------------------------------------------
  rule {
    action   = "rate_based_ban"
    priority = 1000
    match {
      expr {
        expression = "request.path.matches('/api/user/login.*') || request.path.matches('/api/user/register.*')"
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"

      rate_limit_threshold {
        count        = 15
        interval_sec = 60
      }

      ban_threshold {
        count        = 30
        interval_sec = 60
      }
      ban_duration_sec = 900 # 15-minute ban for credential-stuffing attackers
    }
    description = "Rate limit authentication endpoints to prevent credential stuffing"
  }

  # ----------------------------------------------------------------------------
  # Rule 2: OWASP ModSecurity Core Rule Set - SQL Injection & XSS (Priority 2000)
  # ----------------------------------------------------------------------------
  rule {
    action   = "deny(403)"
    priority = 2000
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-v33-stable') || evaluatePreconfiguredExpr('xss-v33-stable')"
      }
    }
    description = "Block OWASP Top 10 SQL Injection and Cross-Site Scripting"
  }

  # ----------------------------------------------------------------------------
  # Rule 3: Default Allow for Legitimate Traffic (Lowest Priority)
  # ----------------------------------------------------------------------------
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule for standard clinic traffic"
  }
}
