terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-4632746528"
    key    = "rancher"
    region = "eu-north-1"
  }
}

provider "aws" {
  profile = "dev"
  region  = "eu-north-1"
}