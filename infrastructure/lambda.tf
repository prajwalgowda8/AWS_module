
# Lambda Function Configuration
module "lambda" {
  source = "${local.module_source}lambda"

  # Function Configuration
  function_name = var.lambda_function_name
  description   = var.lambda_description

  # Runtime Configuration
  runtime      = var.lambda_runtime
  handler      = var.lambda_handler
  package_type = "Zip"

  # Code Configuration (placeholder - will need actual deployment package)
  filename         = null
  s3_bucket        = var.s3_bucket_name
  s3_key          = "lambda/${var.lambda_function_name}.zip"
  source_code_hash = null

  # Performance Configuration
  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  # Architecture
  architectures = ["x86_64"]

  # Environment Variables (optional)
  environment_variables = {
    ENVIRONMENT = var.environment
    LOG_LEVEL   = "INFO"
  }

  # VPC Configuration (disabled by default)
  vpc_config = null

  # Dead Letter Configuration (disabled by default)
  dead_letter_config = null

  # Tracing Configuration
  tracing_config = {
    mode = "Active"
  }

  # Layers (empty by default)
  layers = []

  # Security
  kms_key_arn = null

  # Additional IAM Policies (empty by default)
  additional_policy_arns = []

  # Publishing
  publish = false

  # Logging
  log_retention_days = var.lambda_log_retention_days
  log_kms_key_id     = null

  # Mandatory Tags (Lambda module uses different tag structure)
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
    Component   = "lambda-function"
    ManagedBy   = "terraform"
  }
}

# Outputs for Lambda Function
output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.function_name
}

output "lambda_invoke_arn" {
  description = "ARN to be used for invoking Lambda Function from API Gateway"
  value       = module.lambda.invoke_arn
}

output "lambda_role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  value       = module.lambda.role_arn
}

output "lambda_role_name" {
  description = "Name of the IAM role for the Lambda function"
  value       = module.lambda.role_name
}

output "lambda_log_group_name" {
  description = "CloudWatch log group name"
  value       = module.lambda.log_group_name
}

output "lambda_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = module.lambda.log_group_arn
}
