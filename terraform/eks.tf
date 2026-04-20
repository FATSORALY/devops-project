module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets   # public (pas de NAT = Free Tier)

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    spot_nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 1
      instance_types = ["t3.small", "t3.medium"]
      capacity_type  = "SPOT"   # ~70% moins cher qu'ON_DEMAND

      labels = {
        Environment = "production"
        NodeGroup   = "spot"
      }
    }
  }

  # Add-ons gérés par AWS
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}

# ── IAM Role pour AWS Load Balancer Controller ────────────────────────────────
data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
}
