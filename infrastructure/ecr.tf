
# ECR Repository Configuration
module "ecr" {
  source = "${local.module_source}ecr"

  # Repository Configuration
  repository_name       = var.ecr_repository_name
  image_tag_mutability  = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete

  # Security Configuration
  scan_on_push     = var.ecr_scan_on_push
  encryption_type  = var.ecr_encryption_type
  kms_key_id       = var.ecr_kms_key_id

  # Lifecycle Policy Configuration
  enable_lifecycle_policy = var.ecr_enable_lifecycle_policy
  max_image_count        = var.ecr_max_image_count
  untagged_image_days    = var.ecr_untagged_image_days

  # Mandatory Tags (ECR module uses different tag structure)
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
    Component   = "ecr-repository"
    ManagedBy   = "terraform"
    Repository  = var.ecr_repository_name
  }
}

# Outputs for ECR
output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_registry_id" {
  description = "Registry ID where the repository was created"
  value       = module.ecr.registry_id
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}
