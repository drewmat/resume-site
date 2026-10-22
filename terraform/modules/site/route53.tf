resource "aws_route53_record" "resume_site" {
  name = var.domain_name
  zone_id = data.aws_route53_zone.resume_site_domain.zone_id
  type = "A"
  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.resume_site.domain_name
    zone_id = aws_cloudfront_distribution.resume_site.hosted_zone_id
  }
}