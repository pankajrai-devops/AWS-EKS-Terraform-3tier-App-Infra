variable "cluster_name" {
  type        = string
  description = "The application environment resource designation name assigned to the core EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "The target Kubernetes control plane platform software version track to deploy (e.g. 1.30)"
}

variable "addon_version_vpc_cni" { 
  type = string 
}

variable "addon_version_coredns" {
  type        = string
  description = "The explicit system software version flag mapping the coredns operational plug-in patch track"
}

variable "addon_version_kube_proxy" {
  type        = string
  description = "The explicit system software version flag mapping the kube-proxy network routing plug-in track"
}

variable "addon_version_pod_identity" {
  type        = string
  description = "The explicit system software version flag mapping the AWS Pod Identity agent framework track"
}

variable "addon_version_cloudwatch" {
  type        = string
  description = "The explicit system software version flag mapping the cloudwatch observability collection agent"
}

variable "addon_version_ebs" {
  type        = string
  description = "The explicit system software version flag mapping the EBS Container Storage Interface plug-in driver"
}

variable "addon_version_efs" {
  type        = string
  description = "The explicit system software version flag mapping the EFS Container Storage Interface plug-in driver"
}

variable "cluster_role_arn" {
  type        = string
  description = "The secure IAM authorization string token passed down to manage master control operations"
}

variable "node_role_arn" {
  type        = string
  description = "The secure EC2 IAM authorization profile string enabling computational node cluster interactions"
}

variable "cloudwatch_role_arn" {
  type        = string
  description = "The specialized security identity allowing real-time container log extraction pipelines"
}

variable "cloudwatch_policy_attached" {
  type        = string
  description = "A configuration validation constraint tracker ensuring observability waits for explicit role mappings"
}

variable "eks_admin_user_arn" {
  type        = string
  description = "The system resource identification string linking full admin group rights over the cluster control layer"
}

variable "eks_viewer_user_arn" {
  type        = string
  description = "The system resource identification string linking read-only viewer group rights over the cluster control layer"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The network subnet array reference link paths where computing worker machine node sets execute"
}

variable "node_name_prefix" {
  type        = string
  description = "The identification prefix label assigned to structure dynamic instance target pools on creation"
}

variable "node_instance_types" {
  type        = list(string)
  description = "The computing instance virtual hardware classification size arrays configured for cluster worker pools"
}

variable "node_desired_size" {
  type        = number
  description = "The active baseline computational count desired for cluster computing worker pools on initial launch"
}

variable "node_max_size" {
  type        = number
  description = "The absolute elasticity bound ceiling parameter preventing further auto-scaling node increments"
}

variable "node_min_size" {
  type        = number
  description = "The platform scale floor parameter ensuring computing machine counts do not drop beneath base availability needs"
}

variable "node_max_unavailable" {
  type        = number
  description = "The threshold tracking the absolute highest amount of nodes allowed to terminate simultaneously during cluster updates"
}

variable "tags" {
  type        = map(string)
  description = "Tags details"
}