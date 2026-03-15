# EKS Auto Mode Cluster Example

This example demonstrates how to create an Amazon EKS cluster using Auto Mode with the terraform-aws-eks module.

## Features

- **EKS Auto Mode**: Simplified node management with automatic provisioning
- **Private Cluster**: API endpoint accessible only from within VPC
- **KMS Encryption**: Customer-managed key for secrets encryption
- **Comprehensive Logging**: All cluster log types enabled
- **High Availability**: Multi-AZ deployment with private subnets
- **Security Best Practices**: Private subnets, encrypted storage, audit logging

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                          VPC                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   Public AZ-A   │  │   Public AZ-B   │  │ Public AZ-C  │ │
│  │   NAT Gateway   │  │   NAT Gateway   │  │ NAT Gateway  │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │  Private AZ-A   │  │  Private AZ-B   │  │ Private AZ-C │ │
│  │                 │  │                 │  │              │ │
│  │  ┌───────────┐  │  │  ┌───────────┐  │  │ ┌──────────┐ │ │
│  │  │    EKS    │  │  │  │    EKS    │  │  │ │   EKS    │ │ │
│  │  │ Auto Mode │  │  │  │ Auto Mode │  │  │ │Auto Mode │ │ │
│  │  │   Nodes   │  │  │  │   Nodes   │  │  │ │  Nodes   │ │ │
│  │  └───────────┘  │  │  └───────────┘  │  │ └──────────┘ │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Usage

1. **Set Variables**: Copy `terraform.tfvars.example` to `terraform.tfvars` and customize
2. **Initialize**: `terraform init`
3. **Plan**: `terraform plan`
4. **Apply**: `terraform apply`

## Example Configuration

```hcl
namespace   = "myorg"
environment = "dev"
name        = "app-cluster"
region      = "us-east-1"

cluster_version = "1.32"

# Security settings
endpoint_public_access  = false
endpoint_private_access = true

cluster_log_types = [
  "audit",
  "api", 
  "authenticator",
  "controllerManager",
  "scheduler"
]

tags = {
  Project = "my-application"
  Team    = "platform"
}
```

## Connecting to the Cluster

After deployment, configure kubectl:

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name myorg-dev-app-cluster

# Verify connection
kubectl get nodes
kubectl get pods -A
```

## Security Features

- **Private API Endpoint**: Cluster API only accessible from VPC
- **KMS Encryption**: Secrets encrypted with customer-managed key
- **Audit Logging**: Comprehensive cluster activity logging
- **Network Isolation**: Nodes in private subnets only
- **IAM Integration**: OIDC provider for service account authentication

## Auto Mode Benefits

- **Simplified Operations**: No need to manage node groups or Fargate profiles
- **Automatic Scaling**: Nodes scale based on pod requirements
- **Cost Optimization**: Pay only for resources actually used
- **Reduced Complexity**: AWS manages node lifecycle and updates

## Cleanup

```bash
terraform destroy
```

**Note**: Ensure all Kubernetes resources are deleted before destroying the cluster to avoid orphaned AWS resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_cluster"></a> [eks\_cluster](#module\_eks\_cluster) | ../ | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | github.com/islamelkadi/terraform-aws-kms | v1.0.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/islamelkadi/terraform-aws-vpc//modules/vpc | v1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_node_policy_arns"></a> [additional\_node\_policy\_arns](#input\_additional\_node\_policy\_arns) | List of additional IAM policy ARNs to attach to the EKS node role | `list(string)` | `[]` | no |
| <a name="input_cluster_log_types"></a> [cluster\_log\_types](#input\_cluster\_log\_types) | List of EKS cluster log types to enable | `list(string)` | <pre>[<br/>  "audit",<br/>  "api",<br/>  "authenticator",<br/>  "controllerManager",<br/>  "scheduler"<br/>]</pre> | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version for the EKS cluster | `string` | `"1.32"` | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | Whether the EKS cluster API endpoint is accessible from within the VPC | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Whether the EKS cluster API endpoint is publicly accessible | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the EKS cluster | `string` | `"app-cluster"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | `"example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | <pre>{<br/>  "Project": "eks-example"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | EKS cluster ARN |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | EKS cluster endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | EKS cluster name |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | EKS cluster security group ID |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | KMS key ARN |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | KMS key ID |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | OIDC provider ARN for IRSA |
| <a name="output_oidc_provider_url"></a> [oidc\_provider\_url](#output\_oidc\_provider\_url) | OIDC provider URL |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnet IDs |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END_TF_DOCS -->