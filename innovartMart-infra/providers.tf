terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    # NOTE: You MUST create this S3 bucket manually in the AWS Console (in us-east-1) before running terraform init.
    # Replace "project-bedrock-tf-state-YOUR_STUDENT_ID" with the actual bucket name you create.
    bucket = "project-bedrock-tf-state-alt-soe-025-5051"
    key    = "project-bedrock/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = "karatu-2025-capstone"
    }
  }
}
