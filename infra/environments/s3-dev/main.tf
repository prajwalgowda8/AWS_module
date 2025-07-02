
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Local values for environment-specific configuration
locals {
  environment = "dev"
  project     = "sc-s3-demo"
  
  # Common tags for all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedDate = "2025-01-02"
  }
}

# S3 Bucket Module
module "s3_bucket" {
  source = "../../s3_bucket"
  
  # Bucket configuration
  bucket_name   = "sc-s3-demo-${local.environment}-${random_id.bucket_suffix.hex}"
  force_destroy = false
  
  # Versioning and encryption
  versioning_enabled   = true
  encryption_algorithm = "AES256"
  
  # Public access settings (secure by default)
  block_public_access     = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  # Lifecycle configuration
  lifecycle_enabled = true
  lifecycle_rules = [
    {
      id     = "delete_old_versions"
      status = "Enabled"
      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
    },
    {
      id     = "transition_to_ia"
      status = "Enabled"
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]
  
  # Notifications
  notification_enabled = true
  eventbridge_enabled  = true
  
  # Mandatory tags
  common_tags                    = local.common_tags
  contact_group                  = "Storage Team"
  contact_name                   = "Mike Johnson"
  cost_bucket                    = "development"
  data_owner                     = "Data Platform Team"
  display_name                   = "SC S3 Demo Development"
  environment                    = local.environment
  has_public_ip                  = "false"
  has_unisys_network_connection  = "false"
  service_line                   = "Storage Services"
}

# Random ID for bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Output bucket information
output "bucket_id" {
  description = "S3 bucket ID"
  value       = module.s3_bucket.bucket_id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3_bucket.bucket_arn
}

output "bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = module.s3_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = module.s3_bucket.bucket_regional_domain_name
}

output "bucket_region" {
  description = "S3 bucket region"
  value       = module.s3_bucket.bucket_region
}

output "versioning_status" {
  description = "S3 bucket versioning status"
  value       = module.s3_bucket.versioning_status
}

output "encryption_algorithm" {
  description = "S3 bucket encryption algorithm"
  value       = module.s3_bucket.encryption_algorithm
}

output "public_access_block_enabled" {
  description = "Whether public access block is enabled"
  value       = module.s3_bucket.public_access_block_enabled
}

output "lifecycle_enabled" {
  description = "Whether lifecycle configuration is enabled"
  value       = module.s3_bucket.lifecycle_enabled
}

output "eventbridge_enabled" {
  description = "Whether EventBridge notifications are enabled"
  value       = module.s3_bucket.eventbridge_enabled
}
