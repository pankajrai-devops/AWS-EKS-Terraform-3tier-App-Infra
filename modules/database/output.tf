output "cluster_endpoint" { 
    value = aws_rds_cluster.aurora.endpoint
}
output "cluster_reader_endpoint" { 
    value = aws_rds_cluster.aurora.reader_endpoint 
}
output "database_name" { 
    value = aws_rds_cluster.aurora.database_name 
}
output "secret_manager_arn" { 
    value = aws_secretsmanager_secret.db_credentials.arn 
}
