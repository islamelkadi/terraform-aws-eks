# VPC for EKS cluster
# This creates a VPC with private subnets for secure EKS deployment

module "vpc" {
  source = "git::https://github.com/islamelkadi/terraform-aws-vpc.git//modules/vpc?ref=v1.0.1"

  namespace   = var.namespace
  environment = var.environment
  name        = "${var.name}-vpc"
  region      = var.region

  # VPC configuration
  cidr_block = "10.0.0.0/16"

  # Availability zones (use first 3 AZs in region)
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]

  # Subnet configuration
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Enable NAT Gateway for private subnet internet access
  enable_nat_gateway = true
  single_nat_gateway = false # Use one NAT per AZ for HA

  # Enable VPC Flow Logs
  enable_flow_logs = true

  # DNS settings
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Purpose = "EKS Cluster VPC"
    }
  )
}