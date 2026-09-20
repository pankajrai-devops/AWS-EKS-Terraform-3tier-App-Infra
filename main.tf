terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.16.0"
}

provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2       = "http://localhost:5001"
    eks       = "http://localhost:5001"
    iam       = "http://localhost:5001"
    rds       = "http://localhost:5001"
    route53   = "http://localhost:5001"
    s3        = "http://localhost:5001"
    sts       = "http://localhost:5001"
  }
}

data "aws_availability_zones" "available" { state = "available" }

module "network" {
  source                        = "./modules/network"
  vpc_cidr                      = var.vpc_cidr
  public_subnet_cidr            = var.public_subnet_cidr
  public_subnet2_cidr           = var.public_subnet2_cidr
  eks_az1_cidr                  = var.eks_az1_cidr
  eks_az2_cidr                  = var.eks_az2_cidr
  eks_az3_cidr                  = var.eks_az3_cidr
  db_az1_cidr                   = var.db_az1_cidr
  db_az2_cidr                   = var.db_az2_cidr
  db_az3_cidr                   = var.db_az3_cidr
  cluster_name                  = var.cluster_name
  vpc_name_tag                  = var.vpc_name_tag
  igw_name_tag                  = var.igw_name_tag
  region                        = var.region
  tags                          = var.tags
  az_1                          = data.aws_availability_zones.available.names.0
  az_2                          = data.aws_availability_zones.available.names.1
  az_3                          = data.aws_availability_zones.available.names.2
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
}

module "iam" {
  source              = "./modules/iam"
  cluster_name        = var.cluster_name
  eks_admin_username  = var.eks_admin_username
  eks_viewer_username = var.eks_viewer_username
  tags                = var.tags
}

module "eks" {
  source                     = "./modules/eks"
  cluster_name               = var.cluster_name
  cluster_version            = var.cluster_version
  addon_version_vpc_cni      = var.addon_version_vpc_cni
  addon_version_coredns      = var.addon_version_coredns
  addon_version_kube_proxy   = var.addon_version_kube_proxy
  addon_version_pod_identity = var.addon_version_pod_identity
  addon_version_cloudwatch   = var.addon_version_cloudwatch
  addon_version_ebs          = var.addon_version_ebs
  addon_version_efs          = var.addon_version_efs
  cluster_role_arn           = module.iam.cluster_role_arn
  node_role_arn              = module.iam.node_role_arn
  cloudwatch_role_arn        = module.iam.cloudwatch_role_arn
  cloudwatch_policy_attached = module.iam.cloudwatch_role_policy_attachment_id
  eks_admin_user_arn         = module.iam.admin_user_arn
  eks_viewer_user_arn        = module.iam.viewer_user_arn
  subnet_ids                 = module.network.eks_subnet_ids
  node_name_prefix           = var.node_name_prefix
  node_instance_types        = var.node_instance_types
  node_desired_size          = var.node_desired_size
  node_max_size              = var.node_max_size
  node_min_size              = var.node_min_size
  node_max_unavailable       = var.node_max_unavailable
  tags                       = var.tags
}

module "database" {
  source                 = "./modules/database"
  cluster_name           = var.cluster_name
  vpc_id                 = module.network.vpc_id
  subnet_ids             = module.network.db_subnet_ids
  eks_security_group_id  = module.eks.cluster_security_group_id
  db_engine              = var.db_engine
  db_engine_version      = var.db_engine_version
  db_name                = var.db_name
  db_master_username     = var.db_master_username
  db_instance_class      = var.db_instance_class
  db_instance_count      = var.db_instance_count
  secret_recovery_window = var.secret_recovery_window
  tags                   = var.tags
}

module "registry" {
  source                  = "./modules/registry"
  repository_name         = var.repository_name
  image_mutability        = var.image_mutability
  scan_on_push            = var.scan_on_push
  encryption_type         = var.encryption_type
  untagged_lifecycle_days = var.untagged_lifecycle_days
  tags                    = var.tags
}
