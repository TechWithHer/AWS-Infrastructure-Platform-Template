variable "project_name" {
description = "Input the Unique Name of the Project"
  type        = string

  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name cannot be empty."
  }
}


variable "aws_region" {
  description = "Select the valid AWS region"
  type        = string
  default     = "ap-southeast-1"
}
