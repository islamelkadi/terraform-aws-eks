# EKS Auto Mode Cluster Module
# Creates an Amazon EKS cluster with Auto Mode enabled, private endpoint,
# KMS secrets encryption, audit logging, and OIDC provider

# IAM Role for EKS Cluster
data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${local.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy",
  ])

  role       = aws_iam_role.cluster.name
  policy_arn = each.value
}

# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  # Auto Mode requires self-managed addons to be disabled
  bootstrap_self_managed_addons = false

  # Auto Mode configuration
  compute_config {
    enabled       = true
    node_pools    = ["general-purpose", "system"]
    node_role_arn = aws_iam_role.node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  # VPC configuration — private endpoint only
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    security_group_ids      = concat(
      var.create_security_group ? [aws_security_group.cluster[0].id] : [],
      var.additional_security_group_ids
    )
  }

  # KMS secrets encryption
  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  # Audit logging
  enabled_cluster_log_types = var.cluster_log_types

  # Access configuration
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  tags = local.tags

  depends_on = [aws_iam_role_policy_attachment.cluster]
}

# IAM Role for EKS Auto Mode Nodes
data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "node" {
  name               = "${local.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset(concat(
    [
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    ],
    var.additional_node_policy_arns,
  ))

  role       = aws_iam_role.node.name
  policy_arn = each.value
}

# OIDC Provider for IRSA (IAM Roles for Service Accounts)
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = local.tags
}
# Custom Security Group (optional)
resource "aws_security_group" "cluster" {
  count = var.create_security_group ? 1 : 0

  name        = var.security_group_name != null ? var.security_group_name : "${local.cluster_name}-sg"
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(local.tags, {
    Name = var.security_group_name != null ? var.security_group_name : "${local.cluster_name}-sg"
  })
}

# Security Group Ingress Rules
resource "aws_security_group_rule" "ingress" {
  count = var.create_security_group ? length(var.ingress_rules) : 0

  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = var.ingress_rules[count.index].cidr_blocks
  ipv6_cidr_blocks  = var.ingress_rules[count.index].ipv6_cidr_blocks
  source_security_group_id = var.ingress_rules[count.index].source_security_group_id
  self              = var.ingress_rules[count.index].self
  description       = var.ingress_rules[count.index].description
  security_group_id = aws_security_group.cluster[0].id
}

# Security Group Egress Rules
resource "aws_security_group_rule" "egress" {
  count = var.create_security_group ? length(var.egress_rules) : 0

  type                     = "egress"
  from_port                = var.egress_rules[count.index].from_port
  to_port                  = var.egress_rules[count.index].to_port
  protocol                 = var.egress_rules[count.index].protocol
  cidr_blocks              = var.egress_rules[count.index].cidr_blocks
  ipv6_cidr_blocks         = var.egress_rules[count.index].ipv6_cidr_blocks
  source_security_group_id = var.egress_rules[count.index].destination_security_group_id
  self                     = var.egress_rules[count.index].self
  description              = var.egress_rules[count.index].description
  security_group_id        = aws_security_group.cluster[0].id
}