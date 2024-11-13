terraform {
  required_version = ">= 1.3.0"

  # State Storage and Locking
  # backend "s3" {
  #   region         = "us-east-1"
  #   bucket         = "terraform-559050208886"
  #   key            = "iam"
  #   dynamodb_table = "terraform_lock"
  # }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

data "aws_caller_identity" "self" {}