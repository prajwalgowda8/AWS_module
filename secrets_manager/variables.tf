
variable "secret_name" {
  description = "Name of the secret"
  type        = string
  default     = "sc-secrets-dbcreds-demo"
}

variable "secret_description" {
  description = "Description of the secret"
  type        = string
  default     = "Database credentials storage for sc-secrets-dbcreds-demo"
}

variable "secret_string" {
  description = "Secret string value (JSON format for structured secrets)"
  type        = string
  default     = null
  sensitive   = true
}

variable "secret_binary" {
  description = "Secret binary value (base64 encoded)"
  type        = string
  default     = null
  sensitive   = true
}

variable "recovery_window_in_days" {
  description = "Number of days before permanent deletion (0 to force deletion, or 7-30 days)"
  type        = number
  default     = 30
  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "Recovery window must be 0 (force deletion) or between 7 and 30 days."
  }
}

# KMS Configuration
variable "create_kms_key" {
  description = "Create a dedicated KMS key for this secret"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN or ID of existing KMS key to use (if create_kms_key is false)"
  type        = string
  default     = null
}

variable "kms_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
  validation {
    condition     = var.kms_deletion_window >= 7 && var.kms_deletion_window <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "enable_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

variable "key_rotation_period" {
  description = "KMS key rotation period in days"
  type        = number
  default     = 365
  validation {
    condition     = var.key_rotation_period >= 90 && var.key_rotation_period <= 2560
    error_message = "Key rotation period must be between 90 and 2560 days."
  }
}

# Replication Configuration
variable "replica_regions" {
  description = "List of regions to replicate the secret to"
  type = list(object({
    region     = string
    kms_key_id = optional(string)
  }))
  default = []
}

# Secret Policy Configuration
variable "secret_policy" {
  description = "JSON policy document for the secret"
  type        = string
  default     = null
}

variable "block_public_policy" {
  description = "Block public access to the secret policy"
  type        = bool
  default     = true
}

# Automatic Rotation Configuration
variable "enable_automatic_rotation" {
  description = "Enable automatic rotation for the secret"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "ARN of existing Lambda function for rotation (if not creating new one)"
  type        = string
  default     = null
}

variable "create_rotation_lambda_role" {
  description = "Create IAM role for rotation Lambda function"
  type        = bool
  default     = false
}

variable "rotation_days" {
  description = "Number of days between automatic rotations"
  type        = number
  default     = 30
  validation {
    condition     = var.rotation_days >= 1 && var.rotation_days <= 365
    error_message = "Rotation days must be between 1 and 365."
  }
}

variable "rotate_immediately" {
  description = "Rotate the secret immediately upon creation"
  type        = bool
  default     = false
}

variable "secret_type" {
  description = "Type of secret for rotation configuration"
  type        = string
  default     = "rds"
  validation {
    condition     = contains(["generic", "rds", "redshift", "documentdb"], var.secret_type)
    error_message = "Secret type must be one of: generic, rds, redshift, documentdb."
  }
}

variable "rotation_lambda_vpc_config" {
  description = "VPC configuration for rotation Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# Cross-service Access Configuration
variable "allow_lambda_access" {
  description = "Allow Lambda service to access this secret"
  type        = bool
  default     = true
}

variable "allow_ecs_access" {
  description = "Allow ECS tasks to access this secret"
  type        = bool
  default     = true
}

variable "allow_rds_access" {
  description = "Allow RDS service to access this secret"
  type        = bool
  default     = true
}

variable "cross_service_principals" {
  description = "List of additional service principals that can access this secret"
  type        = list(string)
  default     = []
}

variable "cross_account_access" {
  description = "List of AWS account IDs that can access this secret"
  type        = list(string)
  default     = []
}

variable "cross_role_access" {
  description = "List of IAM role ARNs that can access this secret"
  type        = list(string)
  default     = []
}

# Secret Structure Templates
variable "database_secret_template" {
  description = "Use database secret template structure"
  type        = bool
  default     = true
}

variable "api_key_secret_template" {
  description = "Use API key secret template structure"
  type        = bool
  default     = false
}

variable "oauth_secret_template" {
  description = "Use OAuth secret template structure"
  type        = bool
  default     = false
}

# Database Secret Configuration (when using database template)
variable "database_config" {
  description = "Database configuration for secret template"
  type = object({
    engine   = string
    host     = string
    port     = number
    dbname   = string
    username = string
    password = string
  })
  default   = null
  sensitive = true
}

# API Key Configuration (when using API key template)
variable "api_key_config" {
  description = "API key configuration for secret template"
  type = object({
    api_key    = string
    api_secret = optional(string)
    endpoint   = optional(string)
  })
  default   = null
  sensitive = true
}

# OAuth Configuration (when using OAuth template)
variable "oauth_config" {
  description = "OAuth configuration for secret template"
  type = object({
    client_id     = string
    client_secret = string
    token_url     = optional(string)
    scope         = optional(string)
  })
  default   = null
  sensitive = true
}

# Mandatory tag variables
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "contact_group" {
  description = "Contact group for the resources"
  type        = string
}

variable "contact_name" {
  description = "Contact name for the resources"
  type        = string
}

variable "cost_bucket" {
  description = "Cost bucket for the resources"
  type        = string
}

variable "data_owner" {
  description = "Data owner for the resources"
  type        = string
}

variable "display_name" {
  description = "Display name for the resources"
  type        = string
}

variable "environment" {
  description = "Environment for the resources"
  type        = string
}

variable "has_public_ip" {
  description = "Whether the resources have public IP"
  type        = string
}

variable "has_unisys_network_connection" {
  description = "Whether the resources have Unisys network connection"
  type        = string
}

variable "service_line" {
  description = "Service line for the resources"
  type        = string
}
