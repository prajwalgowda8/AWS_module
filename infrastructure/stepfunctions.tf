
# Step Functions State Machine Configuration
module "stepfunctions" {
  source = "${local.module_source}step_functions"

  # State Machine Configuration
  state_machine_name = var.stepfunctions_state_machine_name
  type              = var.stepfunctions_type

  # Minimal State Machine Definition (blank/basic state machine)
  definition = jsonencode({
    Comment = "A minimal Step Functions state machine"
    StartAt = "HelloWorld"
    States = {
      HelloWorld = {
        Type   = "Pass"
        Result = "Hello World!"
        End    = true
      }
    }
  })

  # Logging Configuration
  enable_logging           = var.stepfunctions_enable_logging
  log_level               = var.stepfunctions_log_level
  include_execution_data  = false
  log_retention_days      = var.stepfunctions_log_retention_days

  # Tracing Configuration
  enable_tracing = var.stepfunctions_enable_tracing

  # Encryption Configuration
  enable_encryption = var.stepfunctions_enable_encryption
  kms_key_id       = null

  # Publishing
  publish_version = false

  # Service Integrations (empty by default - can be configured later)
  lambda_functions = {}
  sns_topics      = []
  sqs_queues      = []
  s3_buckets      = []

  # Additional IAM Policies
  additional_policy_arns = []
  custom_policy         = null

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
    Component   = "step-functions"
  }
}

# Outputs for Step Functions
output "stepfunctions_state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = module.stepfunctions.state_machine_arn
}

output "stepfunctions_state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = module.stepfunctions.state_machine_name
}

output "stepfunctions_state_machine_status" {
  description = "Current status of the Step Functions state machine"
  value       = module.stepfunctions.state_machine_status
}

output "stepfunctions_role_arn" {
  description = "ARN of the IAM role for the Step Functions state machine"
  value       = module.stepfunctions.role_arn
}

output "stepfunctions_role_name" {
  description = "Name of the IAM role for the Step Functions state machine"
  value       = module.stepfunctions.role_name
}

output "stepfunctions_log_group_name" {
  description = "CloudWatch log group name (if logging is enabled)"
  value       = module.stepfunctions.log_group_name
}

output "stepfunctions_log_group_arn" {
  description = "CloudWatch log group ARN (if logging is enabled)"
  value       = module.stepfunctions.log_group_arn
}
