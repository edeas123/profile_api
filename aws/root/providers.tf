terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.25.0"
    }
  }

  backend "s3" {
    bucket = "mybytesni-terraform-state"
    key = "my-resume-serverless/root"
    region = "us-east-1"
    dynamodb_table = "mybytesni-terraform-state"
    profile = "mybytesni"
    encrypt = true
  }
}


provider "aws" {
  region  = "us-east-1"
  profile = "mybytesni"
}

