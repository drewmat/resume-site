# Create source bucket in S3
resource "aws_s3_bucket" "resume_site" {
  bucket = var.bucket_name
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "resume_site" {
  bucket = aws_s3_bucket.resume_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Enable public access to the bucket
resource "aws_s3_bucket_public_access_block" "resume_site" {
  bucket = aws_s3_bucket.resume_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "allow_public_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:getObject"
    ]
    resources = ["${aws_s3_bucket.resume_site.arn}/*"]
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = ["${aws_cloudfront_distribution.resume_site.arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "resume_site" {
  bucket = aws_s3_bucket.resume_site.id
  policy = data.aws_iam_policy_document.allow_public_access.json
}

# Upload the files
resource "aws_s3_object" "resume_site" {
    bucket = aws_s3_bucket.resume_site.id

    for_each = fileset("../content/", "**/*.*")
    key    = each.value
    source = "../content/${each.value}"
    etag = filemd5("../content/${each.value}")
}