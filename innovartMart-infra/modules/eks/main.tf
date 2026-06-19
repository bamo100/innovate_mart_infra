resource "aws_iam_policy" "alb_controller" {
  name        = "${var.project_name}-alb-controller-policy"
  description = "IAM Policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/alb_policy.json")
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name = "${var.project_name}-cluster"
  # As per requirements, EKS version >= 1.34.0
  cluster_version = "1.34"

  cluster_endpoint_public_access = true

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.subnet_ids

  # Requirement 4.4: Enable EKS Control Plane logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  cluster_addons = {
    amazon-cloudwatch-observability = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    default = {
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      instance_types = ["t3.medium"]
      iam_role_additional_policies = {
        DynamoDBAccess  = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
        ALBController   = aws_iam_policy.alb_controller.arn
        CloudWatchAgent = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      }
    }
  }

  # Use EKS Access Entries to map IAM User to Kubernetes RBAC
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    dev_view = {
      kubernetes_groups = []
      principal_arn     = var.dev_user_arn

      # AmazonEKSViewPolicy grants the equivalent of 'view' ClusterRole
      policy_associations = {
        view_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
