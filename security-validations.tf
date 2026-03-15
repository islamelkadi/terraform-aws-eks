# Security validations for EKS module
# Enforces AWS Security Hub EKS controls with override capability
#
# Controls enforced:
#   EKS.1 — Cluster endpoint not publicly accessible
#   EKS.2 — Kubernetes version >= 1.32
#   EKS.3 — Secrets encrypted with KMS
#   EKS.6 — Cluster tagged
#   EKS.7 — Identity provider configs tagged
#   EKS.8 — Audit logging enabled

locals {
  # EKS.1 — Private endpoint
  eks1_required = local.security_controls.network.block_public_ingress && !var.security_control_overrides.disable_private_endpoint
  eks1_passed   = !local.eks1_required || !var.endpoint_public_access

  # EKS.2 — Kubernetes version >= 1.32
  eks2_required = !var.security_control_overrides.disable_version_check
  eks2_passed   = !local.eks2_required || tonumber(var.cluster_version) >= 1.32

  # EKS.3 — KMS secrets encryption
  eks3_required = local.security_controls.encryption.require_encryption_at_rest && !var.security_control_overrides.disable_kms_encryption
  eks3_passed   = !local.eks3_required || var.kms_key_arn != null

  # EKS.6 — Cluster tagged
  eks6_required = !var.security_control_overrides.disable_cluster_tagging
  eks6_passed   = !local.eks6_required || length(local.tags) > 0

  # EKS.7 — Identity provider configs tagged
  eks7_required = !var.security_control_overrides.disable_idp_tagging
  eks7_passed   = !local.eks7_required || length(local.tags) > 0

  # EKS.8 — Audit logging enabled
  eks8_required = local.security_controls.logging.require_access_logging && !var.security_control_overrides.disable_audit_logging
  eks8_passed   = !local.eks8_required || contains(var.cluster_log_types, "audit")

  # Override audit trail
  has_overrides = (
    var.security_control_overrides.disable_private_endpoint ||
    var.security_control_overrides.disable_version_check ||
    var.security_control_overrides.disable_kms_encryption ||
    var.security_control_overrides.disable_cluster_tagging ||
    var.security_control_overrides.disable_idp_tagging ||
    var.security_control_overrides.disable_audit_logging
  )
  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}

# Security control validations
check "security_controls_compliance" {
  assert {
    condition     = local.eks1_passed
    error_message = "EKS.1: Cluster endpoint must not be publicly accessible. Set endpoint_public_access=false. Override with security_control_overrides.disable_private_endpoint=true and justification."
  }

  assert {
    condition     = local.eks2_passed
    error_message = "EKS.2: Kubernetes version must be >= 1.32. Current: ${var.cluster_version}. Override with security_control_overrides.disable_version_check=true and justification."
  }

  assert {
    condition     = local.eks3_passed
    error_message = "EKS.3: Secrets must be encrypted with a KMS key. Provide kms_key_arn. Override with security_control_overrides.disable_kms_encryption=true and justification."
  }

  assert {
    condition     = local.eks6_passed
    error_message = "EKS.6: Cluster must be tagged. Provide tags via the tags variable. Override with security_control_overrides.disable_cluster_tagging=true and justification."
  }

  assert {
    condition     = local.eks7_passed
    error_message = "EKS.7: Identity provider configs must be tagged. Provide tags via the tags variable. Override with security_control_overrides.disable_idp_tagging=true and justification."
  }

  assert {
    condition     = local.eks8_passed
    error_message = "EKS.8: Audit logging must be enabled. Include 'audit' in cluster_log_types. Override with security_control_overrides.disable_audit_logging=true and justification."
  }

  assert {
    condition     = local.override_audit_passed
    error_message = "Security control overrides detected but no justification provided. Set security_control_overrides.justification to document the business reason for disabling security controls."
  }
}