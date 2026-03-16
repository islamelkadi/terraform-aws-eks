# Primary Module Example - This demonstrates the terraform-aws-eks module
# Supporting infrastructure (KMS, VPC) is defined in separate files
# to keep this example focused on the module's core functionality.
#
# EKS Auto Mode Cluster Example

# External Security Group (demonstrates additional_security_group_ids)
resource "aws_security_group" "external" {
  name        = "${var.namespace}-${var.environment}-${var.name}-external-sg"
  description = "External security group for EKS cluster demonstration"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "HTTPS from private networks"
  }

  tags = merge(var.tags, {
    Name = "${var.namespace}-${var.environment}-${var.name}-external-sg"
  })
}

module "eks_cluster" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  # Cluster configuration
  cluster_version = var.cluster_version

  # Network configuration - use private subnets for security
  subnet_ids = module.vpc.private_subnet_ids

  # Security Group Configuration (demonstrates both patterns)
  create_security_group         = var.create_security_group
  vpc_id                        = module.vpc.vpc_id
  security_group_description    = "Custom security group for EKS cluster with additional rules"
  additional_security_group_ids = var.create_security_group ? [] : [aws_security_group.external.id]

  # Custom ingress rules (only used if create_security_group is true)
  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "HTTPS from VPC"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "HTTP from VPC"
    }
  ]

  # Security configuration
  kms_key_arn                 = module.kms_key.key_arn
  endpoint_public_access      = var.endpoint_public_access
  endpoint_private_access     = var.endpoint_private_access
  cluster_log_types           = var.cluster_log_types
  additional_node_policy_arns = var.additional_node_policy_arns

  tags = var.tags
}