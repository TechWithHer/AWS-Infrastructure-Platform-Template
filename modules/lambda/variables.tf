variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "schedule_expression" {
  type    = string
  default = "rate(1 day)"
}