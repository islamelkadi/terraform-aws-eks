# Outputs for EKS example

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_cluster.cluster_name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks_cluster.cluster_arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks_cluster.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL"
  value       = module.eks_cluster.oidc_provider_url
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks_cluster.cluster_security_group_id
}

# KMS Key outputs
output "kms_key_id" {
  description = "KMS key ID"
  value       = module.kms_key.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = module.kms_key.key_arn
}

# VPC outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}
output "custom_security_group_id" {
  description = "ID of the custom security group (if created)"
  value       = module.eks_cluster.security_group_id
}

output "external_security_group_id" {
  description = "ID of the external security group"
  value       = aws_security_group.external.id
}

output "all_security_group_ids" {
  description = "All security group IDs attached to the EKS cluster"
  value       = module.eks_cluster.all_security_group_ids
}