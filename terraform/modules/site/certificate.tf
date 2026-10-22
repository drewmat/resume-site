resource "aws_acm_certificate" "resume_site" {
  domain_name = var.domain_name
  validation_method = "DNS"
}

data "aws_route53_zone" "resume_site_domain" {
    name = var.route53_zone
}

resource "aws_route53_record" "resume_site_certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.resume_site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.resume_site_domain.zone_id
}