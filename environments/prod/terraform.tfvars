service_name = "demo-web"

# prod runs multiple instances on distinct ports (demonstrates for_each scaling)
instances = {
  blue  = { host_port = 9091 }
  green = { host_port = 9092 }
}
