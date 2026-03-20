resource "aws_iam_user" "github-actions" {
  name = "github-actions-${terraform.workspace}"
  path = "/"
}

resource "aws_iam_access_key" "github-actions" {
  user = aws_iam_user.github-actions.name

  lifecycle {
    ignore_changes = [status]
  }
}

# ── Policy 1: S3 ─────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "github-actions-s3" {
  statement {
    sid    = "SiteBucketObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
    ]
    resources = ["${aws_s3_bucket.resume_site.arn}/*"]
  }

  statement {
    sid    = "SiteBucketManage"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy",
      "s3:DeleteBucketPolicy",
      "s3:GetBucketWebsite",
      "s3:PutBucketWebsite",
      "s3:DeleteBucketWebsite",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketAcl",
      "s3:ListBucket",
      "s3:GetBucketTagging",
      "s3:PutBucketTagging",
      "s3:GetBucketCORS",                   # Terraform state refresh on aws_s3_bucket
      "s3:GetBucketObjectLockConfiguration", # Terraform state refresh on aws_s3_bucket
      "s3:GetBucketRequestPayment",          # Terraform state refresh on aws_s3_bucket
      "s3:GetBucketVersioning",              # Terraform state refresh on aws_s3_bucket
      "s3:GetAccelerateConfiguration",       # Terraform state refresh on aws_s3_bucket
      "s3:GetEncryptionConfiguration",       # Terraform state refresh on aws_s3_bucket
      "s3:GetLifecycleConfiguration",        # Terraform state refresh on aws_s3_bucket
      "s3:GetReplicationConfiguration",      # Terraform state refresh on aws_s3_bucket
    ]
    resources = [aws_s3_bucket.resume_site.arn]
  }

  statement {
    sid    = "TerraformStateObjects"
    effect = "Allow"
    actions = ["s3:*"]
    resources = ["arn:aws:s3:::${var.backend_bucket}/*/resumesite/terraform.tfstate"]
  }

  statement {
    sid    = "TerraformStateBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning",
    ]
    resources = ["arn:aws:s3:::${var.backend_bucket}"]
  }
}

resource "aws_iam_policy" "github-actions-s3" {
  name   = "github-actions-s3-${terraform.workspace}"
  policy = data.aws_iam_policy_document.github-actions-s3.json
}

resource "aws_iam_user_policy_attachment" "github-actions-s3" {
  user       = aws_iam_user.github-actions.name
  policy_arn = aws_iam_policy.github-actions-s3.arn
}

# ── Policy 2: CloudFront ──────────────────────────────────────────────────────
data "aws_iam_policy_document" "github-actions-cloudfront" {
  statement {
    sid    = "CloudFrontManage"
    effect = "Allow"
    actions = [
      "cloudfront:CreateDistribution",
      "cloudfront:UpdateDistribution",
      "cloudfront:DeleteDistribution",
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudfront:TagResource",
      "cloudfront:CreateOriginAccessControl",
      "cloudfront:UpdateOriginAccessControl",
      "cloudfront:DeleteOriginAccessControl",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:GetOriginAccessControlConfig",
      "cloudfront:ListOriginAccessControls",
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
      "cloudfront:ListInvalidations",
    ]
    # CloudFront ARNs are unknown pre-creation so resource scoping is not possible
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github-actions-cloudfront" {
  name   = "github-actions-cloudfront-${terraform.workspace}"
  policy = data.aws_iam_policy_document.github-actions-cloudfront.json
}

resource "aws_iam_user_policy_attachment" "github-actions-cloudfront" {
  user       = aws_iam_user.github-actions.name
  policy_arn = aws_iam_policy.github-actions-cloudfront.arn
}

# ── Policy 3: ACM + Route53 ───────────────────────────────────────────────────
data "aws_iam_policy_document" "github-actions-dns" {
  statement {
    sid    = "ACMManage"
    effect = "Allow"
    actions = [
      "acm:RequestCertificate",
      "acm:DescribeCertificate",
      "acm:DeleteCertificate",
      "acm:ListCertificates",
      "acm:AddTagsToCertificate",
      "acm:ListTagsForCertificate",
    ]
    # ACM ARNs are unknown pre-creation so resource scoping is not possible
    resources = ["*"]
  }

  statement {
    sid    = "Route53Manage"
    effect = "Allow"
    actions = [
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListTagsForResource",    # Required by aws_route53_zone data source refresh
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github-actions-dns" {
  name   = "github-actions-dns-${terraform.workspace}"
  policy = data.aws_iam_policy_document.github-actions-dns.json
}

resource "aws_iam_user_policy_attachment" "github-actions-dns" {
  user       = aws_iam_user.github-actions.name
  policy_arn = aws_iam_policy.github-actions-dns.arn
}

# ── Policy 4: IAM self-management ─────────────────────────────────────────────
data "aws_iam_policy_document" "github-actions-iam" {
  statement {
    sid    = "IAMManagePolicies"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",            # Required by Terraform to refresh managed policy state
      "iam:GetPolicyVersion",     # Required alongside GetPolicy during state refresh
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:AttachUserPolicy",
      "iam:DetachUserPolicy",
      "iam:ListAttachedUserPolicies",
    ]
    # Scoped to only the workspace-named policies this user manages
    resources = [
      "arn:aws:iam::*:policy/github-actions-s3-development",
      "arn:aws:iam::*:policy/github-actions-s3-production",
      "arn:aws:iam::*:policy/github-actions-cloudfront-development",
      "arn:aws:iam::*:policy/github-actions-cloudfront-production",
      "arn:aws:iam::*:policy/github-actions-dns-development",
      "arn:aws:iam::*:policy/github-actions-dns-production",
      "arn:aws:iam::*:policy/github-actions-iam-development",
      "arn:aws:iam::*:policy/github-actions-iam-production",
    ]
  }

  statement {
    sid    = "IAMManageGithubActionsUser"
    effect = "Allow"
    actions = [
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:GetUser",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:TagUser",
      "iam:UntagUser",
    ]
    # Scoped to workspace-named users: github-actions-development, github-actions-production
    resources = [
      "arn:aws:iam::*:user/github-actions-development",
      "arn:aws:iam::*:user/github-actions-production",
    ]
  }
}

resource "aws_iam_policy" "github-actions-iam" {
  name   = "github-actions-iam-${terraform.workspace}"
  policy = data.aws_iam_policy_document.github-actions-iam.json
}

resource "aws_iam_user_policy_attachment" "github-actions-iam" {
  user       = aws_iam_user.github-actions.name
  policy_arn = aws_iam_policy.github-actions-iam.arn
}
