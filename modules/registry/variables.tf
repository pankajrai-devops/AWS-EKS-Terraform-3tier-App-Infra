variable "repository_name" { 
    type = string 
}
variable "image_mutability" { 
    type = string 
}
variable "scan_on_push" { 
    type = bool 
}
variable "encryption_type" { 
    type = string 
}
variable "untagged_lifecycle_days" { 
    type = number 
}
variable "tags" { 
    type = map(string) 
}