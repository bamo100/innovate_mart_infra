variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "project-bedrock"
}

variable "student_id" {
  description = "Your unique student ID to append to S3 buckets"
  type        = string
  default     = "alt-soe-025-5051"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
