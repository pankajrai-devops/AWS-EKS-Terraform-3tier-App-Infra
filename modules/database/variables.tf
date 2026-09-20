variable "cluster_name" { 
    type = string 
}
variable "vpc_id" { 
    type = string 
}
variable "subnet_ids" {
     type = list(string) 
}
variable "eks_security_group_id" { 
    type = string 
}
variable "db_engine" { 
    type = string 
}
variable "db_engine_version" { 
    type = string 
}
variable "db_name" {
     type = string 
}
variable "db_master_username" { 
    type = string 
}
variable "db_instance_class" { 
    type = string 
}
variable "db_instance_count" { 
    type = number 
}
variable "secret_recovery_window" { 
    type = number 
}
variable "tags" { 
    type = map(string) 
}