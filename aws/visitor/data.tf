locals {
  region  = "us-east-1"
  service = "visitor"
  table = "ProfileVisitor"
  domain = "iamobaro.com"
}


data "aws_caller_identity" "current" {}
