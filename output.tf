output "vpc_id" { 
    value = module.network.vpc_id 
}
output "public_nat_gateway_ips" { 
    value = module.network.nat_gateway_ips 
}
output "eks_cluster_name" { 
    value = module.eks.cluster_name 
}
output "eks_cluster_endpoint" { 
    value = module.eks.cluster_endpoint 
}
/* output "eks_cluster_certificate_authority_data" { 
    value = module.eks.cluster_ca_data
    sensitive = true 
} */
output "aurora_cluster_endpoint" { 
    value = module.database.cluster_endpoint 
}
output "aurora_cluster_reader_endpoint" { 
    value = module.database.cluster_reader_endpoint 
}
output "aurora_database_name" { 
    value = module.database.database_name 
}
output "aurora_secret_manager_arn" { 
    value = module.database.secret_manager_arn 
}
output "ecr_repository_url" { 
    value = module.registry.repository_url 
}
output "ecr_repository_arn" { 
    value = module.registry.repository_arn 
}
output "eks_admin_iam_user_arn" { 
    value = module.iam.admin_user_arn 
}
output "eks_viewer_iam_user_arn" { 
    value = module.iam.viewer_user_arn 
}

/*output "nginx_ingress_nlb_hostname" {
    value = module.ingress.nlb_hostname 
} */
