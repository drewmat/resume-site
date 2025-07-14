resource "aws_cloudfront_distribution" "resume_site" {
  enabled = true

  aliases = [ var.domain_name ]

  origin {
    domain_name = aws_s3_bucket.resume_site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.resume_site.id
    origin_id = var.bucket_name
  }

  default_cache_behavior {
    allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = var.bucket_name
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = ["US", "CA", "GB"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.resume_site.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  }

  price_class = "PriceClass_100"
}

resource "aws_cloudfront_origin_access_control" "resume_site" {
  name = terraform.workspace == "default" ? "resume_site_s3" : "resume_site_dev_s3"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}