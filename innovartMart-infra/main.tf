module "network" {
  source       = "./modules/network"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "eks" {
  source       = "./modules/eks"
  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnets
  dev_user_arn = module.iam.dev_user_arn
}

module "database" {
  source           = "./modules/database"
  project_name     = var.project_name
  vpc_id           = module.network.vpc_id
  database_subnets = module.network.private_subnets
  source_cidr      = var.vpc_cidr
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "serverless" {
  source       = "./modules/serverless"
  project_name = var.project_name
  student_id   = var.student_id
  dev_user_arn = module.iam.dev_user_arn
}

resource "tls_private_key" "cert" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.cert.private_key_pem

  subject {
    common_name  = "*.elb.amazonaws.com"
    organization = "Project Bedrock"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.cert.private_key_pem
  certificate_body = tls_self_signed_cert.cert.cert_pem
}
