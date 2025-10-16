provider "aws" {
  region = "us-east-1"
}

terraform {
  cloud {
    organization = "practice-lab-"
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