terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  # Key matches the state previously held in the "production" workspace,
  # so no state migration is needed.
  backend "s3" {
    bucket = "expecttheimpossible-terraform"
    key    = "env:/production/resumesite/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "site" {
  source = "../../modules/site"

  bucket_name  = "www.andyengdahl.com"
  domain_name  = "www.andyengdahl.com"
  route53_zone = "andyengdahl.com"
  oac_name     = "resume_site_s3"
}

# Resources were previously declared at the root; map them into the module.
moved {
  from = aws_acm_certificate.resume_site
  to   = module.site.aws_acm_certificate.resume_site
}
moved {
  from = aws_route53_record.resume_site_certificate_validation
  to   = module.site.aws_route53_record.resume_site_certificate_validation
}
moved {
  from = aws_route53_record.resume_site
  to   = module.site.aws_route53_record.resume_site
}
moved {
  from = aws_cloudfront_distribution.resume_site
  to   = module.site.aws_cloudfront_distribution.resume_site
}
moved {
  from = aws_cloudfront_origin_access_control.resume_site
  to   = module.site.aws_cloudfront_origin_access_control.resume_site
}
moved {
  from = aws_s3_bucket.resume_site
  to   = module.site.aws_s3_bucket.resume_site
}
moved {
  from = aws_s3_bucket_website_configuration.resume_site
  to   = module.site.aws_s3_bucket_website_configuration.resume_site
}
moved {
  from = aws_s3_bucket_public_access_block.resume_site
  to   = module.site.aws_s3_bucket_public_access_block.resume_site
}
moved {
  from = aws_s3_bucket_policy.resume_site
  to   = module.site.aws_s3_bucket_policy.resume_site
}
# Content is now uploaded by the content workflow. Drop the objects from state
# without deleting them from the bucket.
removed {
  from = aws_s3_object.resume_site

  lifecycle {
    destroy = false
  }
}

output "s3_bucket_name" {
  value = module.site.s3_bucket_name
}

output "cloudfront_distribution_id" {
  value = module.site.cloudfront_distribution_id
}
