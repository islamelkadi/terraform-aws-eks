# EKS Auto Mode Cluster Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "attributes" {
  description = "Additional attributes for naming"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to use between name components"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# EKS-specific variables
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster (must be >= 1.32)"
  type        = string
  default     = "1.32"

  validation {
    condition     = tonumber(var.cluster_version) >= 1.32
    error_message = "Cluster version must be >= 1.32"
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster (private subnets recommended)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs are required for EKS cluster high availability"
  }
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for EKS secrets encryption"
  type        = string
}

variable "cluster_log_types" {
  description = "List of EKS cluster log types to enable"
  type        = list(string)
  default     = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
}

variable "additional_node_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the EKS node role (beyond the default EKSWorkerNodeMinimalPolicy and ECR pull policies)"
  type        = list(string)
  default     = []
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

# Security Controls
variable "security_controls" {
  description = "Security controls configuration from metadata module. Used to enforce security standards"
  type = object({
    encryption = object({
      require_kms_customer_managed  = bool
      require_encryption_at_rest    = bool
      require_encryption_in_transit = bool
      enable_kms_key_rotation       = bool
    })
    logging = object({
      require_cloudwatch_logs = bool
      min_log_retention_days  = number
      require_access_logging  = bool
      require_flow_logs       = bool
    })
    monitoring = object({
      enable_xray_tracing         = bool
      enable_enhanced_monitoring  = bool
      enable_performance_insights = bool
      require_cloudtrail          = bool
    })
    network = object({
      require_private_subnets = bool
      require_vpc_endpoints   = bool
      block_public_ingress    = bool
      require_imdsv2          = bool
    })
    compliance = object({
      enable_point_in_time_recovery = bool
      require_reserved_concurrency  = bool
      enable_deletion_protection    = bool
    })
  })
  default = null
}

# Security Control Overrides
variable "security_control_overrides" {
  description = <<-EOT
    Override specific security controls for this EKS cluster.
    Only use when there's a documented business justification.

    IMPORTANT: Document the reason in the 'justification' field for audit purposes.
  EOT

  type = object({
    disable_private_endpoint = optional(bool, false)
    disable_version_check    = optional(bool, false)
    disable_kms_encryption   = optional(bool, false)
    disable_cluster_tagging  = optional(bool, false)
    disable_idp_tagging      = optional(bool, false)
    disable_audit_logging    = optional(bool, false)

    # Audit trail - document why controls are disabled
    justification = optional(string, "")
  })

  default = {
    disable_private_endpoint = false
    disable_version_check    = false
    disable_kms_encryption   = false
    disable_cluster_tagging  = false
    disable_idp_tagging      = false
    disable_audit_logging    = false
    justification            = ""
  }
}