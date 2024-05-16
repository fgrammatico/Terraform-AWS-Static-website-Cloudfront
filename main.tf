provider "aws" {
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "harkom-web-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "harkom-web-terraform-state-lock"
  }
}

module "cloudfront" {
  source = "./modules/"

  SiteTags          = var.SiteTags
  domainName        = var.domainName
}