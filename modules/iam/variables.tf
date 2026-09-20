variable "cluster_name" {
    type = string
}

variable "eks_admin_username" {
    type = string
}

variable "eks_viewer_username" {
    type = string
}

variable "tags" {
    type = map(string)
}