output "certificate_arn" {
  description = "The ARN of the issued ACM TLS certificate"
  value       = aws_acm_certificate.cert.arn
}

output "certificate_status" {
  description = "The current validation status of the certificate"
  value       = aws_acm_certificate.cert.status
}

output "dns_validation_records" {
  description = "CNAME records required for DNS validation if managing DNS outside of Route 53"
  value = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      record_name  = dvo.resource_record_name
      record_type  = dvo.resource_record_type
      record_value = dvo.resource_record_value
    }
  }
}
