terraform {
  cloud {
    organization = "daily_practice_hcl_tf"
    workspaces {
      name = "HNG-DevOps1"
    }

  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}