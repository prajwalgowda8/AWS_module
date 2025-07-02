
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
  project     = "sc-secrets-dbcreds-demo"
  
  # Common tags for all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedDate = "2025-01-02"
  }
  
  # Sample database configuration
  database_credentials = {
    engine   = "postgres"
    host     = "sc-rds-postgres-demo.cluster-xyz.us-east-1.rds.amazonaws.com"
    port     = 5432
    dbname   = "postgres"
    username = "postgres"
    password = random_password.db_password.result
  }
}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Secrets Manager Module for Database Credentials
module "database_secrets" {
  source = "../../secrets_manager"
  
  # Secret configuration
  secret_name        = "sc-secrets-dbcreds-demo"
  secret_description = "Database credentials storage for sc-secrets-dbcreds-demo"
  
  # Use database template
  database_secret_template = true
  database_config          = local.database_credentials
  
  # KMS encryption
  create_kms_key      = true
  enable_key_rotation = true
  key_rotation_period = 365
  
  # Security settings
  recovery_window_in_days = 30
  block_public_policy     = true
  
  # Cross-service access
  allow_lambda_access = true
  allow_ecs_access    = true
  allow_rds_access    = true
  
  # Rotation configuration (disabled for demo)
  enable_automatic_rotation    = false
  create_rotation_lambda_role  = false
  rotation_days               = 30
  secret_type                 = "rds"
  
  # Mandatory tags
  common_tags                    = local.common_tags
  contact_group                  = "Database Team"
  contact_name                   = "David Chen"
  cost_bucket                    = "development"
  data_owner                     = "Database Administration Team"
  display_name                   = "SC Secrets Database Credentials Demo Development"
  environment                    = local.environment
  has_public_ip                  = "false"
  has_unisys_network_connection  = "false"
  service_line                   = "Security Services"
}

# Additional secret for API keys (example)
module "api_key_secrets" {
  source = "../../secrets_manager"
  
  # Secret configuration
  secret_name        = "sc-secrets-apikeys-demo"
  secret_description = "API keys storage for external services"
  
  # Use API key template
  api_key_secret_template = true
  api_key_config = {
    api_key    = "demo-api-key-12345"
    api_secret = "demo-api-secret-67890"
    endpoint   = "https://api.example.com"
  }
  
  # Use existing KMS key from database secrets
  create_kms_key = false
  kms_key_id     = module.database_secrets.kms_key_arn
  
  # Security settings
  recovery_window_in_days = 7
  block_public_policy     = true
  
  # Cross-service access
  allow_lambda_access = true
  allow_ecs_access    = false
  allow_rds_access    = false
  
  # No rotation for API keys
  enable_automatic_rotation = false
  secret_type              = "generic"
  
  # Mandatory tags
  common_tags                    = local.common_tags
  contact_group                  = "API Team"
  contact_name                   = "David Chen"
  cost_bucket                    = "development"
  data_owner                     = "Integration Team"
  display_name                   = "SC Secrets API Keys Demo Development"
  environment                    = local.environment
  has_public_ip                  = "false"
  has_unisys_network_connection  = "false"
  service_line                   = "Security Services"
}

# Output secrets information
output "database_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = module.database_secrets.secret_arn
}

output "database_secret_name" {
  description = "Name of the database credentials secret"
  value       = module.database_secrets.secret_name
}

output "database_kms_key_arn" {
  description = "ARN of the KMS key for database secrets"
  value       = module.database_secrets.kms_key_arn
}

output "database_kms_alias_name" {
  description = "Name of the KMS key alias for database secrets"
  value       = module.database_secrets.kms_alias_name
}

output "api_key_secret_arn" {
  description = "ARN of the API key secret"
  value       = module.api_key_secrets.secret_arn
}

output "api_key_secret_name" {
  description = "Name of the API key secret"
  value       = module.api_key_secrets.secret_name
}

output "lambda_environment_variables" {
  description = "Environment variables for Lambda functions"
  value = {
    database = module.database_secrets.lambda_environment_variables
    api_keys = module.api_key_secrets.lambda_environment_variables
  }
}

output "ecs_secrets_config" {
  description = "ECS secrets configuration"
  value = {
    database_secrets = module.database_secrets.ecs_secrets_config
    api_key_secrets  = module.api_key_secrets.ecs_secrets_config
  }
}

output "secret_access_config" {
  description = "Secret access configuration"
  value = {
    database_access = module.database_secrets.access_config
    api_key_access  = module.api_key_secrets.access_config
  }
}

output "security_config" {
  description = "Security configuration for secrets"
  value = {
    database_security = module.database_secrets.security_config
    api_key_security  = module.api_key_secrets.security_config
  }
}
