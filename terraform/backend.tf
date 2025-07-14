terraform {
  backend "s3" {
    bucket = "expecttheimpossible-terraform"
    key = "resumesite/terraform.tfstate"
    region = "us-east-1"
  }
}