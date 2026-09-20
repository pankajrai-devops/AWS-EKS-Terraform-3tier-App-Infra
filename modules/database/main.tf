resource "aws_db_subnet_group" "aurora" {
  name       = "${lower(var.cluster_name)}-aurora-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "aurora-db-subnet-group" })
}

resource "aws_security_group" "aurora" {
  name        = "${var.cluster_name}-aurora-sg"
  description = "Restricted ingress wrapper envelope tracking PostgreSQL parameters"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "aurora-postgresql-sg" })
}

resource "aws_security_group_rule" "aurora_ingress_postgresql" {
  description              = "PostgreSQL securely from EKS Nodes group boundary"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.aurora.id
  source_security_group_id = var.eks_security_group_id
  #depends_on = [aws_security_group.aurora]
  #above was added to test against moto server
}

resource "aws_security_group_rule" "aurora_egress_isolated" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.aurora.id
  cidr_blocks       = ["127.0.0.1/32"]
  #depends_on = [aws_security_group.aurora]
  #above was added to test against moto server
}

resource "random_password" "db_password" { 
    length = 16 
    special = true 
    override_special = "!#$%&*()-_=+[]{}<>:?" 
}

resource "aws_secretsmanager_secret" "db_credentials" { 
    name = "${var.cluster_name}-aurora-secret" 
    recovery_window_in_days = var.secret_recovery_window
    tags = var.tags 
}

resource "aws_secretsmanager_secret_version" "db_credentials_val" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = <<EOF
{
  "username": "${var.db_master_username}",
  "password": "${random_password.db_password.result}"
}
EOF
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = "${var.cluster_name}-aurora-cluster"
  engine                 = var.db_engine
  engine_mode            = "provisioned"
  engine_version         = var.db_engine_version
  database_name          = var.db_name
  master_username        = var.db_master_username
  master_password        = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]
  skip_final_snapshot    = true
  tags                   = merge(var.tags, { Name = "aurora-postgresql-cluster" })
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = var.db_instance_count
  identifier          = "${var.cluster_name}-aurora-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = var.db_instance_class
  engine              = aws_rds_cluster.aurora.engine
  engine_version      = aws_rds_cluster.aurora.engine_version
  publicly_accessible = false
  tags                = merge(var.tags, { Name = "aurora-postgresql-instance-${count.index}" })
}