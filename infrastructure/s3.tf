
# S3 Bucket Configuration
module "s3_bucket" {
  source = "${local.module_source}s3_bucket"

  # Bucket Configuration
  bucket_name   = var.s3_bucket_name
  force_destroy = var.s3_force_destroy

  # Versioning Configuration
  versioning_enabled = var.s3_versioning_enabled

  # Encryption Configuration
  encryption_algorithm = var.s3_encryption_algorithm

  # Public Access Block Configuration
  block_public_access     = var.s3_block_public_access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Lifecycle Configuration
  lifecycle_enabled = var.s3_lifecycle_enabled
  lifecycle_rules   = []

  # Notification Configuration
  notification_enabled = var.s3_notification_enabled
  eventbridge_enabled  = false

  # Mandatory Organizational Tags
  contact_group                 = var.contact_group
  contact_name                  = var.contact_name
  cost_bucket                   = var.cost_bucket
  data_owner                    = var.data_owner
  display_name                  = var.display_name
  environment                   = var.environment
  has_public_ip                 = var.has_public_ip
  has_unisys_network_connection = var.has_unisys_network_connection
  service_line                  = var.service_line

  # Common tags
  common_tags = {
    Project     = var.project_name
    ManagedBy   = "terraform"
    Component   = "s3-bucket"
    BucketType  = "General Purpose"
  }
}

# Outputs for S3 Bucket
output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3_bucket.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = module.s3_bucket.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = module.s3_bucket.bucket_regional_domain_name
}

output "s3_bucket_region" {
  description = "AWS region of the S3 bucket"
  value       = module.s3_bucket.bucket_region
}

output "s3_versioning_status" {
  description = "Versioning status of the S3 bucket"
  value       = module.s3_bucket.versioning_status
}
