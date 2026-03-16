# Terraform AWS EKS Auto Mode Module

[![Terraform Security](https://github.com/islamelkadi/terraform-aws-eks/actions/workflows/terraform-security.yaml/badge.svg)](https://github.com/islamelkadi/terraform-aws-eks/actions/workflows/terraform-security.yaml)
[![Terraform Lint & Validation](https://github.com/islamelkadi/terraform-aws-eks/actions/workflows/terraform-lint.yaml/badge.svg)](https://github.com/islamelkadi/terraform-aws-eks/actions/workflows/terraform-lint.yaml)
[![Terraform Docs](https://github.com/islamelkadi/terraform-aws-eks/actions/workflows/terraform-docs.yaml/badge.svg)](https://github.com/islamelkadi/terraform-aws-eks/actions/workflows/terraform-docs.yaml)

This module creates an Amazon EKS cluster with Auto Mode enabled, private API endpoint, KMS secrets encryption, audit logging, and an OIDC provider for IRSA.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Security](#security)
- [Features](#features)
- [Usage](#usage)
- [Requirements](#requirements)

## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:

```bash
make bootstrap
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.

## Security

### AWS Security Hub EKS Controls

This module enforces all 6 AWS Security Hub EKS controls via `check` blocks in `security-validations.tf`:

- [x] **EKS.1**: Cluster endpoint not publicly accessible
- [x] **EKS.2**: Kubernetes version >= 1.32
- [x] **EKS.3**: Secrets encrypted with KMS customer-managed key
- [x] **EKS.6**: Cluster properly tagged
- [x] **EKS.7**: Identity provider configs tagged
- [x] **EKS.8**: Audit logging enabled

### Security Control Overrides

Each control can be overridden with a documented justification using the `security_control_overrides` variable. Overrides without justification will trigger a validation error.

### Security Scan Suppressions

This module suppresses certain Checkov checks documented in `.checkov.yaml`:

- **Module Source Versioning (CKV_TF_1, CKV_TF_2)**: Uses semantic version tags for readability
- **EKS Secrets Encryption (CKV_AWS_58)**: Configured via `encryption_config` block

## Features

- EKS Auto Mode with Karpenter-managed default NodePools
- Private API endpoint (public access disabled by default)
- KMS encryption for Kubernetes secrets
- Full cluster logging (audit, api, authenticator, controllerManager, scheduler)
- OIDC provider for IAM Roles for Service Accounts (IRSA)
- IAM roles for cluster and nodes with least-privilege policies
- Security Hub compliance validation at plan time
- Standardized naming and tagging via metadata module

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.36.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_iam_openid_connect_provider.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy_document.cluster_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.node_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.cluster](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_node_policy_arns"></a> [additional\_node\_policy\_arns](#input\_additional\_node\_policy\_arns) | List of additional IAM policy ARNs to attach to the EKS node role (beyond the default EKSWorkerNodeMinimalPolicy and ECR pull policies) | `list(string)` | `[]` | no |
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | List of additional security group IDs to attach to the EKS cluster (externally managed) | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_cluster_log_types"></a> [cluster\_log\_types](#input\_cluster\_log\_types) | List of EKS cluster log types to enable | `list(string)` | <pre>[<br/>  "audit",<br/>  "api",<br/>  "authenticator",<br/>  "controllerManager",<br/>  "scheduler"<br/>]</pre> | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version for the EKS cluster (must be >= 1.32) | `string` | `"1.32"` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create a custom security group for the EKS cluster (in addition to EKS-managed security groups) | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | List of egress rules for the custom security group | <pre>list(object({<br/>    from_port                     = number<br/>    to_port                       = number<br/>    protocol                      = string<br/>    cidr_blocks                   = optional(list(string), [])<br/>    ipv6_cidr_blocks              = optional(list(string), [])<br/>    destination_security_group_id = optional(string)<br/>    self                          = optional(bool, false)<br/>    description                   = optional(string, "")<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "description": "Allow all outbound traffic",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | Whether the EKS cluster API endpoint is accessible from within the VPC | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Whether the EKS cluster API endpoint is publicly accessible | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of ingress rules for the custom security group | <pre>list(object({<br/>    from_port                = number<br/>    to_port                  = number<br/>    protocol                 = string<br/>    cidr_blocks              = optional(list(string), [])<br/>    ipv6_cidr_blocks         = optional(list(string), [])<br/>    source_security_group_id = optional(string)<br/>    self                     = optional(bool, false)<br/>    description              = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key for EKS secrets encryption | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls for this EKS cluster.<br/>Only use when there's a documented business justification.<br/><br/>IMPORTANT: Document the reason in the 'justification' field for audit purposes. | <pre>object({<br/>    disable_private_endpoint = optional(bool, false)<br/>    disable_version_check    = optional(bool, false)<br/>    disable_kms_encryption   = optional(bool, false)<br/>    disable_cluster_tagging  = optional(bool, false)<br/>    disable_idp_tagging      = optional(bool, false)<br/>    disable_audit_logging    = optional(bool, false)<br/><br/>    # Audit trail - document why controls are disabled<br/>    justification = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_audit_logging": false,<br/>  "disable_cluster_tagging": false,<br/>  "disable_idp_tagging": false,<br/>  "disable_kms_encryption": false,<br/>  "disable_private_endpoint": false,<br/>  "disable_version_check": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module. Used to enforce security standards | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    network = object({<br/>      require_private_subnets = bool<br/>      require_vpc_endpoints   = bool<br/>      block_public_ingress    = bool<br/>      require_imdsv2          = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description for the custom security group | `string` | `"Custom security group for EKS cluster"` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name for the custom security group (if create\_security\_group is true) | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the EKS cluster (private subnets recommended) | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the security group will be created (required if create\_security\_group is true) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_security_group_ids"></a> [all\_security\_group\_ids](#output\_all\_security\_group\_ids) | List of all security group IDs attached to the EKS cluster (custom + additional + EKS-managed) |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the EKS cluster |
| <a name="output_cluster_certificate_authority"></a> [cluster\_certificate\_authority](#output\_cluster\_certificate\_authority) | Base64 encoded certificate authority data for the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint URL for the EKS cluster API server |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the EKS cluster |
| <a name="output_cluster_role_arn"></a> [cluster\_role\_arn](#output\_cluster\_role\_arn) | ARN of the EKS cluster IAM role |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ID attached to the EKS cluster (managed by EKS) |
| <a name="output_node_role_arn"></a> [node\_role\_arn](#output\_node\_role\_arn) | ARN of the EKS node IAM role |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the OIDC provider for IRSA |
| <a name="output_oidc_provider_url"></a> [oidc\_provider\_url](#output\_oidc\_provider\_url) | URL of the OIDC provider (without https://) |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the custom security group (if created) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the custom security group (if created) |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the EKS cluster |

## Example

See [example/](example/) for a complete working example with all features.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->
