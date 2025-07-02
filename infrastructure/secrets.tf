
# Secrets Manager Configuration
module "secrets_manager" {
  source = "${local.module_source}secrets_manager"

  # Secret Configuration
  secret_name        = var.secrets_secret_name
  secret_description = var.secrets_secret_description

  # KMS Configuration
  create_kms_key       = var.secrets_create_kms_key
  enable_key_rotation  = true
  kms_deletion_window  = 30

  # Recovery Configuration
  recovery_window_in_days = var.secrets_recovery_window_in_days

  # Rotation Configuration
  enable_automatic_rotation    = var.secrets_enable_automatic_rotation
  rotation_days               = var.secrets_rotation_days
  create_rotation_lambda_role = false
  rotate_immediately          = false
  secret_type                 = "rds"

  # Access Configuration
  allow_lambda_access = var.secrets_allow_lambda_access
  allow_ecs_access    = var.secrets_allow_ecs_access
  allow_rds_access    = var.secrets_allow_rds_access

  # Cross-service Access (empty by default)
  cross_service_principals = []
  cross_account_access     = []
  cross_role_access        = []

  # Secret Template Configuration
  database_secret_template = true
  api_key_secret_template  = false
  oauth_secret_template    = false

  # Database Configuration (placeholder - will be populated by RDS module)
  database_config = {
    engine   = "postgres"
    host     = "placeholder-host"
    port     = 5432
    dbname   = var.rds_db_name
    username = var.rds_db_username
    password = "placeholder-password"
  }

  # Replication (empty by default)
  replica_regions = []

  # Policy Configuration
  secret_policy       = null
  block_public_policy = true

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
    Component   = "secrets-manager"
  }
}

# Outputs for Secrets Manager
output "secrets_secret_arn" {
  description = "ARN of the secret"
  value       = module.secrets_manager.secret_arn
}

output "secrets_secret_id" {
  description = "ID of the secret"
  value       = module.secrets_manager.secret_id
}

output "secrets_secret_name" {
  description = "Name of the secret"
  value       = module.secrets_manager.secret_name
}

output "secrets_kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = module.secrets_manager.kms_key_arn
}

output "secrets_kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = module.secrets_manager.kms_key_id
}

output "secrets_rotation_enabled" {
  description = "Whether automatic rotation is enabled"
  value       = module.secrets_manager.rotation_enabled
}
