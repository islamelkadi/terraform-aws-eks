# KMS Key for EKS cluster encryption
# This creates a customer-managed KMS key for encrypting EKS secrets

module "kms_key" {
  source = "github.com/islamelkadi/terraform-aws-kms?ref=v1.0.2"

  namespace   = var.namespace
  environment = var.environment
  name        = "${var.name}-eks"
  region      = var.region

  description = "KMS key for EKS cluster ${var.name} secrets encryption"

  # Allow EKS service to use the key
  service_principals = ["eks.amazonaws.com"]

  tags = merge(
    var.tags,
    {
      Purpose = "EKS Cluster Encryption"
    }
  )
}