variable "service_name" {
  type    = string
  default = "demo-web"
}

variable "instances" {
  type = map(object({
    host_port = number
  }))
}
