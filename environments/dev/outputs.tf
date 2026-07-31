output "vpc_id" {
  value = module.networking.vpc_id
}

output "instance_public_ip" {
  value = module.compute.public_ip
}

output "instance_private_ip" {
  value = module.compute.private_ip
}

