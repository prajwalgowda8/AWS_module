
output "secret_arn" {
  description = "ARN of the secret"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_id" {
  description = "ID of the secret"
  value       = aws_secretsmanager_secret.this.id
}

output "secret_name" {
  description = "Name of the secret"
  value       = aws_secretsmanager_secret.this.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = var.create_kms_key ? aws_kms_key.secrets_manager_key[0].arn : var.kms_key_id
}

output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = var.create_kms_key ? aws_kms_key.secrets_manager_key[0].key_id : null
}

output "kms_alias_name" {
  description = "Name of the KMS key alias"
  value       = var.create_kms_key ? aws_kms_alias.secrets_manager_key_alias[0].name : null
}

output "rotation_enabled" {
  description = "Whether automatic rotation is enabled"
  value       = var.enable_automatic_rotation
}

output "rotation_lambda_role_arn" {
  description = "ARN of the rotation Lambda IAM role (if created)"
  value       = var.enable_automatic_rotation && var.create_rotation_lambda_role ? aws_iam_role.rotation_lambda_role[0].arn : null
}

output "rotation_lambda_role_name" {
  description = "Name of the rotation Lambda IAM role (if created)"
  value       = var.enable_automatic_rotation && var.create_rotation_lambda_role ? aws_iam_role.rotation_lambda_role[0].name : null
}

# Configuration outputs for application integration
output "secret_config" {
  description = "Configuration object for secret integration"
  value = {
    secret_arn              = aws_secretsmanager_secret.this.arn
    secret_name             = aws_secretsmanager_secret.this.name
    kms_key_arn            = var.create_kms_key ? aws_kms_key.secrets_manager_key[0].arn : var.kms_key_id
    rotation_enabled        = var.enable_automatic_rotation
    rotation_days          = var.rotation_days
    secret_type            = var.secret_type
    replica_regions        = var.replica_regions
  }
}

# Access configuration outputs
output "access_config" {
  description = "Access configuration for the secret"
  value = {
    lambda_access_enabled = var.allow_lambda_access
    ecs_access_enabled    = var.allow_ecs_access
    rds_access_enabled    = var.allow_rds_access
    cross_account_access  = var.cross_account_access
    cross_role_access     = var.cross_role_access
  }
}

# Template outputs for structured secrets
output "database_secret_structure" {
  description = "Database secret structure template"
  value = var.database_secret_template ? {
    engine   = var.database_config != null ? var.database_config.engine : null
    host     = var.database_config != null ? var.database_config.host : null
    port     = var.database_config != null ? var.database_config.port : null
    dbname   = var.database_config != null ? var.database_config.dbname : null
    username = var.database_config != null ? var.database_config.username : null
  } : null
  sensitive = false
}

output "api_key_secret_structure" {
  description = "API key secret structure template"
  value = var.api_key_secret_template ? {
    endpoint = var.api_key_config != null ? var.api_key_config.endpoint : null
  } : null
  sensitive = false
}

output "oauth_secret_structure" {
  description = "OAuth secret structure template"
  value = var.oauth_secret_template ? {
    token_url = var.oauth_config != null ? var.oauth_config.token_url : null
    scope     = var.oauth_config != null ? var.oauth_config.scope : null
  } : null
  sensitive = false
}

# Security outputs
output "security_config" {
  description = "Security configuration for the secret"
  value = {
    kms_encryption_enabled = var.create_kms_key || var.kms_key_id != null
    key_rotation_enabled   = var.enable_key_rotation
    recovery_window_days   = var.recovery_window_in_days
    block_public_policy    = var.block_public_policy
    replica_count         = length(var.replica_regions)
  }
}

# Rotation configuration outputs
output "rotation_config" {
  description = "Rotation configuration for the secret"
  value = var.enable_automatic_rotation ? {
    rotation_days         = var.rotation_days
    rotation_lambda_arn   = var.rotation_lambda_arn
    rotate_immediately    = var.rotate_immediately
    secret_type          = var.secret_type
    vpc_configured       = var.rotation_lambda_vpc_config != null
  } : null
}
