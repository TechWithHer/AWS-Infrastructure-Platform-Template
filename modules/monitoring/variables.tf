variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_id" {
  type = string
}

variable "alarm_email" {
  type = string
}
variable "cpu_threshold" {
  description = "CPU utilization percentage before alarm"
  type        = number
  default     = 70
}

variable "evaluation_periods" {
  type    = number
  default = 2
}

variable "period" {
  type    = number
  default = 300
}