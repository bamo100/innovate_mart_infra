output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "assets_bucket_name" {
  description = "The S3 bucket for assets"
  value       = module.serverless.bucket_name
}

output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions to use via OIDC"
  value       = module.iam.github_actions_role_arn
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate for ALB TLS termination"
  value       = aws_acm_certificate.cert.arn
}

output "retail_store_url" {
  description = "The ALB URL to access the Retail Store"
  value       = "https://k8s-retailap-ui-6039ab69e6-1519555346.us-east-1.elb.amazonaws.com"
}
