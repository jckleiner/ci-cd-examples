variable "app_tag_name" {
  description = "Name tag of the application"
  type        = string
  default     = "blabla"
}

variable "ami_id" {
  type        = string
  description = "The id of the machine image to use for the server"

  validation {
    condition     = length(var.ami_id) > 4 && substr(var.ami_id, 0, 4) == "ami-"
    error_message = "Must be a valid AMI id, starting with ami-"
  }
}
