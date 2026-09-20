resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "://amazonaws.com"
      }
    }
  ]
}
EOF
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role" "eks_nodes" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "://amazonaws.com"
      }
    }
  ]
}
EOF
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "ebs_csi" { 
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "efs_csi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role" "cloudwatch_observability" {
  name = "${var.cluster_name}-cloudwatch-observability-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "://amazonaws.com"
      }
    },
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.://amazonaws.com"
      }
    }
  ]
}
EOF
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_observability.name
}

resource "aws_iam_role_policy_attachment" "xray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  role       = aws_iam_role.cloudwatch_observability.name
}

resource "aws_iam_user" "admin" {
  name = var.eks_admin_username
  tags = var.tags
}

resource "aws_iam_user" "viewer" {
  name = var.eks_viewer_username
  tags = var.tags
}

resource "aws_iam_policy" "eks_admin_console" {
  name        = "${var.cluster_name}-admin-console-policy"
  description = "Administrative platform read permissions to describe full control plane components"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters",
        "eks:ListNodegroups",
        "eks:DescribeNodegroup",
        "eks:ListUpdates",
        "eks:DescribeUpdate",
        "eks:ListAddons",
        "eks:DescribeAddon",
        "eks:ListAccessEntries"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "eks_viewer_console" {
  name        = "${var.cluster_name}-viewer-console-policy"
  description = "Minimal read-only visibility rights to check basic cluster inventory"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters",
        "eks:ListNodegroups",
        "eks:DescribeNodegroup"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "admin_console" {
  user       = aws_iam_user.admin.name
  policy_arn = aws_iam_policy.eks_admin_console.arn
}

resource "aws_iam_user_policy_attachment" "viewer_console" {
  user       = aws_iam_user.viewer.name
  policy_arn = aws_iam_policy.eks_viewer_console.arn
}