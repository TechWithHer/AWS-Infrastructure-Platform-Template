locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc" "this" {

  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
  Name = "${var.project_name}-${var.environment}-vpc"
})
}
# Create public subnet 1

resource "aws_subnet" "public_1" {

  vpc_id = aws_vpc.this.id

  cidr_block = var.public_subnet_1_cidr

  availability_zone = var.availability_zone_1

  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
  Name = "${var.project_name}-${var.environment}-vpc"
})
}

# Create public subnet 2

resource "aws_subnet" "public_2" {

  vpc_id = aws_vpc.this.id

  cidr_block = var.public_subnet_2_cidr

  availability_zone = var.availability_zone_2

  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
  Name = "${var.project_name}-${var.environment}-vpc"
})
}

# Create an Internet Gateway

resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
  Name = "${var.project_name}-${var.environment}-vpc"
})
}

# Create a public route table

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
  Name = "${var.project_name}-${var.environment}-vpc"
})
}

# Add Internet Route

resource "aws_route" "internet" {

  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.this.id
}

# Associate the Rouute Table for Subnet 1

resource "aws_route_table_association" "public_1" {

  subnet_id = aws_subnet.public_1.id

  route_table_id = aws_route_table.public.id
}

# Associate the Route Table for Subnet 2

resource "aws_route_table_association" "public_2" {

  subnet_id = aws_subnet.public_2.id

  route_table_id = aws_route_table.public.id
}

