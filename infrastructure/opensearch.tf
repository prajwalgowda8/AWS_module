
# Data source to get current AWS account ID for access policy
data "aws_caller_identity" "current" {}

# OpenSearch Domain Configuration
module "opensearch" {
  source = "${local.module_source}opensearch"

  # Domain Configuration
  domain_name    = var.opensearch_domain_name
  engine_version = var.opensearch_engine_version

  # Cluster Configuration
  instance_type            = var.opensearch_instance_type
  instance_count          = var.opensearch_instance_count
  zone_awareness_enabled  = var.opensearch_zone_awareness_enabled
  availability_zone_count = var.opensearch_availability_zone_count

  # Master Node Configuration (disabled for single AZ)
  dedicated_master_enabled = false

  # EBS Configuration
  ebs_enabled  = var.opensearch_ebs_enabled
  volume_type  = var.opensearch_volume_type
  volume_size  = var.opensearch_volume_size

  # Security Configuration
  encrypt_at_rest           = var.opensearch_encrypt_at_rest
  node_to_node_encryption   = var.opensearch_node_to_node_encryption
  enforce_https            = var.opensearch_enforce_https
  tls_security_policy      = "Policy-Min-TLS-1-2-2019-07"

  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.opensearch_subnet_ids

  # Security Group Configuration - Allow access from EKS security group
  allowed_security_groups = [module.eks.cluster_security_group_id]

  # Fine-grained Access Control
  advanced_security_enabled        = var.opensearch_advanced_security_enabled
  anonymous_auth_enabled           = false
  internal_user_database_enabled   = var.opensearch_internal_user_database_enabled
  master_user_name                = var.opensearch_master_user_name
  master_user_password            = var.opensearch_master_user_password

  # Logging Configuration
  enable_slow_logs        = var.opensearch_enable_slow_logs
  enable_application_logs = var.opensearch_enable_application_logs
  log_retention_days      = var.opensearch_log_retention_days

  # Snapshot Configuration
  automated_snapshot_start_hour = 23

  # Access Policy - Allow all ES actions for domain
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "es:*"
        Resource = "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"
      }
    ]
  })

  # Mandatory Tags (OpenSearch module uses different tag structure)
  mandatory_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.contact_name
    contactGroup                = var.contact_group
    contactName                 = var.contact_name
    costBucket                  = var.cost_bucket
    dataOwner                   = var.data_owner
    displayName                 = var.display_name
    hasPublicIP                 = var.has_public_ip
    hasUnisysNetworkConnection  = var.has_unisys_network_connection
    serviceLine                 = var.service_line
  }

  # Additional tags
  additional_tags = {
    Component   = "opensearch-domain"
    ManagedBy   = "terraform"
  }
}

# Outputs for OpenSearch
output "opensearch_domain_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = module.opensearch.endpoint
}

output "opensearch_domain_arn" {
  description = "ARN of the OpenSearch domain"
  value       = module.opensearch.domain_arn
}

output "opensearch_domain_id" {
  description = "Unique identifier for the OpenSearch domain"
  value       = module.opensearch.domain_id
}

output "opensearch_domain_name" {
  description = "Name of the OpenSearch domain"
  value       = module.opensearch.domain_name
}

output "opensearch_kibana_endpoint" {
  description = "Domain-specific endpoint for Kibana without https scheme"
  value       = module.opensearch.kibana_endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "Domain-specific endpoint for OpenSearch Dashboards without https scheme"
  value       = module.opensearch.dashboard_endpoint
}

output "opensearch_security_group_id" {
  description = "Security group ID for the OpenSearch domain"
  value       = module.opensearch.security_group_id
}

output "opensearch_log_group_name" {
  description = "CloudWatch log group name"
  value       = module.opensearch.log_group_name
}
