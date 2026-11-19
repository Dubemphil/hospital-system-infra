# ==============================================================================
# ACM & Custom Domain Module - devopsstandard.name.ng & api.devopsstandard.name.ng
# Public TLS 1.2+ Certificates for CloudFront & Application Load Balancer
# ==============================================================================

# ------------------------------------------------------------------------------
# Public ACM Certificate (Covering Root Domain, API Subdomain & www)
# ------------------------------------------------------------------------------
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = [var.api_subdomain, "www.${var.domain_name}"]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-acm-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# Route 53 Integration (Enabled when manage_route53 = true)
# ------------------------------------------------------------------------------
data "aws_route53_zone" "main" {
  count        = var.manage_route53 ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

# Automated DNS Validation Records
resource "aws_route53_record" "cert_validation" {
  for_each = var.manage_route53 ? {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id         = data.aws_route53_zone.main[0].zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

# Certificate Validation Waiter
resource "aws_acm_certificate_validation" "cert" {
  count                   = var.manage_route53 ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Route 53 Apex Record: devopsstandard.name.ng -> CloudFront CDN
resource "aws_route53_record" "frontend" {
  count   = var.manage_route53 && var.cloudfront_domain_name != null ? 1 : 0
  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # Static Hosted Zone ID for all Amazon CloudFront distributions
    evaluate_target_health = false
  }
}

# Route 53 Subdomain Record: api.devopsstandard.name.ng -> Application Load Balancer
resource "aws_route53_record" "api" {
  count   = var.manage_route53 && var.alb_dns_name != null ? 1 : 0
  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = var.api_subdomain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

