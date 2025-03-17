variable "bucket_name" {
  type = string
  description = "Bucket name"
}

variable "domain_name" {
    type = string
    description = "Domain name to use"
}

variable "route53_zone" {
    type = string
    description = "route53 zone to place DNS records"
}