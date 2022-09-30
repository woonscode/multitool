terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.24.0"
    }
  }
}

provider "aws" {
  region     = "ap-southeast-1"
  access_key = ""
  secret_key = ""
}

module "vpc" {
  source = "./modules/vpc"
  cluster_name = var.cluster_name
}

resource "aws_iam_role" "eks_cluster" {
  name                = "eks-cluster-role"
  assume_role_policy  = file("./policies/eks-cluster-iam-trust-policy.json")
  managed_policy_arns = var.eks_cluster_policies
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  }

  depends_on = [aws_iam_role.eks_cluster, aws_cloudwatch_log_group.main]
}

resource "aws_cloudwatch_log_group" "main" {
  # The log group name format must be /aws/eks/<cluster-name>/cluster
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
}

data "tls_certificate" "main" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.main.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "alb_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.main.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.main.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.main.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "main_alb" {
  name                = "eks-app-alb-role"
  assume_role_policy  = data.aws_iam_policy_document.alb_trust.json

  inline_policy {
    name = "main_alb_policy"
    policy = file("./policies/alb-iam-policy.json")
  }
}

resource "aws_iam_role" "eks_managed_nodegroup_role" {
  name                = "eks-managed-nodegroup-role"
  assume_role_policy  = file("./policies/eks-managed-node-role-trust-policy.json")
  managed_policy_arns = var.managed_nodegroup_role_policies
}

resource "aws_eks_node_group" "group_1" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "app-managed-nodegroup-1"
  node_role_arn   = aws_iam_role.eks_managed_nodegroup_role.arn
  subnet_ids      = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  ami_type        = "AL2_x86_64"
  # Cost issues, will not work with 2x t3.micro due to ENI IP address limitations, will have little to no IP addresses left for app workload
  instance_types  = ["t3.small"]

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 4
  }

  # Disabled due to nodes being in private subnet but can use bastion host for SSH
  # remote_access {
  #   ec2_ssh_key = "<app key>"
  # }

  depends_on = [aws_iam_role.eks_managed_nodegroup_role]
}

resource "aws_eks_node_group" "group_2" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "app-managed-nodegroup-2"
  node_role_arn   = aws_iam_role.eks_managed_nodegroup_role.arn
  subnet_ids      = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  ami_type        = "AL2_x86_64"
  # Cost issues, will not work with 2x t3.micro due to ENI IP address limitations, will have little to no IP addresses left for app workload
  instance_types  = ["t3.small"]

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 4
  }

  # Disabled due to nodes being in private subnet but can use bastion host for SSH
  # remote_access {
  #   ec2_ssh_key = "<app key>"
  # }

  depends_on = [aws_iam_role.eks_managed_nodegroup_role]
}

# CoreDNS addon a little buggy where it will sometimes schedule both pods on same node and permanently be on degraded state as a result
resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "coredns"
  addon_version     = "v1.8.7-eksbuild.1"
  resolve_conflicts = "OVERWRITE"

  depends_on = [aws_eks_node_group.group_1, aws_eks_node_group.group_2]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "kube-proxy"
  addon_version     = "v1.22.11-eksbuild.2"
  resolve_conflicts = "OVERWRITE"

  depends_on = [aws_eks_node_group.group_1, aws_eks_node_group.group_2]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "vpc-cni"
  addon_version     = "v1.11.2-eksbuild.1"
  resolve_conflicts = "OVERWRITE"

  depends_on = [aws_eks_node_group.group_1, aws_eks_node_group.group_2]
}