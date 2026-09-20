resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version # Hooks into your new version variable

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = var.subnet_ids
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  tags = var.tags
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["://amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.main.identity.0.oidc.0.issuer
  tags            = var.tags
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.node_instance_types
  tags            = var.tags
  node_group_name_prefix = var.node_name_prefix

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }
}

# ------------------------------------------------------------------------------
# FULLY PARAMETERIZED ADDFORWARD PLUGINS
# ------------------------------------------------------------------------------
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "vpc-cni"
  addon_version               = var.addon_version_vpc_cni
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = var.tags
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "coredns"
  addon_version = var.addon_version_coredns
  tags          = var.tags
  depends_on    = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "kube-proxy"
  addon_version = var.addon_version_kube_proxy
  tags          = var.tags
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "aws-pod-identity-agent"
  addon_version = var.addon_version_pod_identity
  tags          = var.tags
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "amazon-cloudwatch-observability"
  addon_version = var.addon_version_cloudwatch
  tags          = var.tags
  depends_on    = [aws_eks_node_group.main, var.cloudwatch_policy_attached]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = var.addon_version_ebs
  tags          = var.tags
  depends_on    = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "efs_csi" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "aws-efs-csi-driver"
  addon_version = var.addon_version_efs
  tags          = var.tags
  depends_on    = [aws_eks_node_group.main]
}

# ------------------------------------------------------------------------------
# GRANULAR ACCESS MAPPINGS
# ------------------------------------------------------------------------------
resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.eks_admin_user_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_policy" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.eks_admin_user_arn
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "viewer" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.eks_viewer_user_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "viewer_policy" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewerPolicy"
  principal_arn = var.eks_viewer_user_arn
  access_scope {
    type = "cluster"
  }
}