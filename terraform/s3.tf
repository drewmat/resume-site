locals {

  # aws_s3_object and fileset methods don't detect MIME types by themselves. They have to be set on a per file basis
  # Create a map of file extensions and their corresponding MIME types.
  mime_map = {
    css         = "text/css"
    eot         = "application/vnd.ms-fontobject"
    html        = "text/html"
    ico         = "image/x-icon"
    jpg         = "image/jpeg"
    js          = "text/javascript"
    png         = "image/png"
    svg         = "image/svg+xml"
    ttf         = "application/x-font-ttf"
    webmanifest = "application/manifest+json"
    woff        = "application/font-woff"
    woff2       = "application/font-woff2"
    xml         = "application/xml"
  }

  # Go through the files in the content directory and load them into the "objects" variable,
  # loading the matching MIME type, defaulting to "text/plain"
  keys = fileset("../content/", "**")
  objects = {
    for key in local.keys : key => {
      content_type = lookup(local.mime_map, reverse(split(".", key))[0], "text/plain")
      source       = "../content/${key}"
    }
  }
}

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
  for_each = local.objects

  bucket       = aws_s3_bucket.resume_site.id
  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source
  source_hash  = filemd5(each.value.source)
}