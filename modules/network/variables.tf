variable "vpc_cidr" {
  type        = string
  description = "The CIDR block allocated for the main VPC architecture"
}

variable "public_subnet_cidr" {
  type        = string
  description = "The primary CIDR block allocation for public subnet 1"
}

variable "public_subnet2_cidr" {
  type        = string
  description = "The secondary CIDR block allocation for public subnet 2"
}

variable "eks_az1_cidr" {
  type        = string
  description = "Private subnet network block for EKS computational nodes in AZ1"
}

variable "eks_az2_cidr" {
  type        = string
  description = "Private subnet network block for EKS computational nodes in AZ2"
}

variable "eks_az3_cidr" {
  type        = string
  description = "Private subnet network block for EKS computational nodes in AZ3"
}

variable "db_az1_cidr" {
  type        = string
  description = "Isolated private subnet block for the database layer instances in AZ1"
}

variable "db_az2_cidr" {
  type        = string
  description = "Isolated private subnet block for the database layer instances in AZ2"
}

variable "db_az3_cidr" {
  type        = string
  description = "Isolated private subnet block for the database layer instances in AZ3"
}

variable "cluster_name" {
  type        = string
  description = "The matching configuration name of the primary Amazon EKS cluster"
}

variable "vpc_name_tag" {
  type        = string
  description = "The structural Name metadata property applied onto the created VPC envelope"
}

variable "igw_name_tag" {
  type        = string
  description = "The functional metadata string applied onto the Internet Gateway instance"
}

variable "az_1" {
  type        = string
  description = "The string name of the first availability zone target passed from root module"
}

variable "az_2" {
  type        = string
  description = "The string name of the second availability zone target passed from root module"
}

variable "az_3" {
  type        = string
  description = "The string name of the third availability zone target passed from root module"
}

variable "region" {
  type        = string
  description = "The target deployment region used to construct AWS service endpoint addresses"
}

variable "eks_cluster_security_group_id" {
  type        = string
  description = "The cluster security group passed down dynamically to allow node communication to endpoints"
}

variable "tags" {
  type        = map(string)
  description = "The mapped infrastructure object tags passed down from root environment"
}