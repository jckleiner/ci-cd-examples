variable "force_destroy" {
    default = false
    type = bool
}

variable "bucket_name" {
    # you can assign the special value null to an argument to mark it as "unset".
    default = null
    type = string
}

variable "enable_versioning" {
    default = false
    type = bool
}

variable "enable_server_side_encryption" {
    default = false
    type = bool
}