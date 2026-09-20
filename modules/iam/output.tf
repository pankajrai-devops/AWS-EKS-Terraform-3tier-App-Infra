output "cluster_role_arn" {
    value = aws_iam_role.eks_cluster.arn
}
output "node_role_arn" {
    value = aws_iam_role.eks_nodes.arn
}
output "cloudwatch_role_arn" { 
    value = aws_iam_role.cloudwatch_observability.arn 
}
output "cloudwatch_role_policy_attachment_id" { 
    value = aws_iam_role_policy_attachment.cw_agent.id
}
output "admin_user_arn" { 
    value = aws_iam_user.admin.arn
}
output "viewer_user_arn" {
    value = aws_iam_user.viewer.arn
}
