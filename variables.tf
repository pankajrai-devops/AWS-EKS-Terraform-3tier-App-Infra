variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "value of the region where the resources will be created"
}

/* variable "environments" {
  type = any
  default = "dev"
  description = "The environment configuration"
} */

variable "vpc_cidr" {
  type        = string
  description = "Base VPC Network Mask"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Subnet block for external-facing entry points (Public Subnet Tier)"
  default     = "10.0.1.0/24"
}

variable "public_subnet2_cidr" {
  type        = string
  description = "Subnet number 2 block for external-facing entry points (Public Subnet Tier)"
  default     = "10.0.2.0/24"
}

variable "eks_az1_cidr" {
  type        = string
  description = "CIDR  block for az1 private subnet for EKS"
  default     = "10.0.3.0/24"
}

variable "eks_az2_cidr" {
  type        = string
  description = "CIDR  block for az2 private subnet for EKS"
  default     = "10.0.4.0/24"
}

variable "eks_az3_cidr" {
  type        = string
  description = "CIDR  block for az3 private subnet for EKS"
  default     = "10.0.5.0/24"
}

variable "db_az1_cidr" {
  type        = string
  description = "CIDR  block for az1 private subnet for database Aurora"
  default     = "10.0.6.0/24"
}

variable "db_az2_cidr" {
  type        = string
  description = "CIDR  block for az2 private subnet for database Aurora"
  default     = "10.0.7.0/24"
}

variable "db_az3_cidr" {
  type        = string
  description = "CIDR  block for az3 private subnet for database Aurora"
  default     = "10.0.8.0/24"
}

variable "cluster_name" {
  type        = string
  default     = "pankaj-eks-cluster"
  description = "The name of the Amazon EKS cluster"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of resource tags to assign to the infrastructure resources"
  default     = {
    Environment = "default"
    ManagedBy   = "terraform"
    Project     = "3-tier-eks"
    Owner       = "Pankaj-Rai"
  }
}

variable "cluster_version" { 
  type = string
  default = "1.35" 
}

variable "addon_version_vpc_cni" { 
  type = string
  default = "v1.18.1-eksbuild.3" 
}

variable "addon_version_coredns" { 
  type = string
  default = "v1.14.3-eksbuild.16" 
}

variable "addon_version_kube_proxy" { 
  type = string
  default = "v1.35.3-eksbuild.25" 
}

variable "addon_version_pod_identity" { 
  type = string 
  default = "v1.3.10-eksbuild.2" 
}

variable "addon_version_cloudwatch" { 
  type = string
  default = "v3.0.0-eksbuild.1" 
}

variable "addon_version_ebs" { 
  type = string
  default = "v1.36.0-eksbuild.1" 
}

variable "addon_version_efs" { 
  type = string
  default = "v1.7.2-eksbuild.1"
}

variable "vpc_name_tag" { 
  type = string
  default = "london-3tier-vpc" 
}

variable "igw_name_tag" { 
  type = string
  default = "main-igw" 
}

variable "node_name_prefix" { 
  type = string
  default = "managed-node-group-" 
}

variable "node_instance_types" { 
  type = list(string)
  default = ["t3.medium"] 
}
variable "node_desired_size" { 
  type = number
  default = 2 
}

variable "node_max_size" { 
  type = number
  default = 4 
}

variable "node_min_size" { 
  type = number
  default = 1 
}

variable "node_max_unavailable" { 
  type = number
  default = 1 
}

variable "db_engine" { 
  type = string
  default = "aurora-postgresql" 
}

variable "db_engine_version" { 
  type = string
  default = "16.1" 
}

variable "db_name" { 
  type = string
  default = "app_production" 
}

variable "db_master_username" { 
  type = string
  default = "postgres_admin" 
}

variable "db_instance_class" { 
  type = string
  default = "db.r6g.large" 
}

variable "db_instance_count" { 
  type = number
  default = 2 
}

variable "secret_recovery_window" { 
  type = number
  default = 0 
}

variable "repository_name" { 
  type = string
  default = "pankaj-app-repo" 
}

variable "image_mutability" {
  type = string
  default = "IMMUTABLE" 
}

variable "scan_on_push" { 
  type = bool
  default = true 
}

variable "encryption_type" { 
  type = string
  default = "AES256" 
}

variable "untagged_lifecycle_days" { 
  type = number
  default = 14 
}

variable "eks_admin_username" { 
  type = string
  default = "pankaj-eks-admin" 
}

variable "eks_viewer_username" {
  type = string
  default = "pankaj-eks-viewer" 
}

variable "ingress_namespace" { 
  type = string
  default = "ingress-nginx"
}

variable "controller_replica_count" { 
  type = number
  default = 2 
}

variable "nlb_name" { 
  type = string
  default = "pankaj-eks-public-nlb" 
}