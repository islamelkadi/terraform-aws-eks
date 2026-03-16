# EKS Module Example Variables

variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Name for the EKS cluster"
  type        = string
  default     = "app-cluster"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster API endpoint is publicly accessible"
  type        = bool
  default     = false
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster API endpoint is accessible from within the VPC"
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "List of EKS cluster log types to enable"
  type        = list(string)
  default     = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
}

variable "additional_node_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the EKS node role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Project = "eks-example"
  }
}
variable "create_security_group" {
  description = "Whether to create a custom security group for the EKS cluster"
  type        = bool
  default     = false
}