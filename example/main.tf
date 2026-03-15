# Primary Module Example - This demonstrates the terraform-aws-eks module
# Supporting infrastructure (KMS, VPC) is defined in separate files
# to keep this example focused on the module's core functionality.
#
# EKS Auto Mode Cluster Example

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

  # Security configuration
  kms_key_arn                 = module.kms_key.key_arn
  endpoint_public_access      = var.endpoint_public_access
  endpoint_private_access     = var.endpoint_private_access
  cluster_log_types           = var.cluster_log_types
  additional_node_policy_arns = var.additional_node_policy_arns

  tags = var.tags
}