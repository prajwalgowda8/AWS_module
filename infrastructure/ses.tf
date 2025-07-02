
# SES Email Service Configuration
module "ses" {
  source = "${local.module_source}ses"

  # Service Configuration
  service_name        = var.ses_service_name
  service_description = "SES email service for ${var.ses_service_name}"

  # Email Configuration
  email_addresses = [var.ses_email_address]
  domain_name     = null
  mail_from_domain = null

  # Configuration Set
  create_configuration_set = var.ses_create_configuration_set
  configuration_set_name   = null
  tls_policy              = var.ses_tls_policy
  reputation_metrics_enabled = var.ses_reputation_metrics_enabled
  sending_enabled         = true

  # Event Destinations
  enable_cloudwatch_destination = var.ses_enable_cloudwatch_destination
  enable_sns_destination        = false
  enable_kinesis_destination    = false

  cloudwatch_matching_types = ["send", "reject", "bounce", "complaint", "delivery"]
  sns_topic_arn            = null
  kinesis_firehose_arn     = null
  kinesis_iam_role_arn     = null

  # Logging Configuration
  log_retention_days = var.ses_log_retention_days
  log_kms_key_id     = null

  # Identity Policies
  create_sending_policy = true
  allowed_senders      = []
  custom_identity_policies = {}

  # Bounce and Complaint Handling
  enable_bounce_topic    = var.ses_enable_bounce_topic
  enable_complaint_topic = var.ses_enable_complaint_topic
  bounce_topic_name      = null
  complaint_topic_name   = null

  # Email Templates (empty by default)
  email_templates = {}

  # Suppression List
  enable_account_level_suppression = true
  suppressed_reasons              = ["BOUNCE", "COMPLAINT"]

  # Dedicated IP Configuration (disabled by default)
  create_dedicated_ip_pool    = false
  dedicated_ip_pool_name      = null
  dedicated_ip_warmup_enabled = true

  # Contact List (disabled by default)
  create_contact_list        = false
  contact_list_name          = null
  contact_list_description   = "Contact list for email campaigns"

  # Monitoring and Alerting
  create_sending_quota_alarm  = var.ses_create_sending_quota_alarm
  sending_quota_threshold     = 80
  create_bounce_rate_alarm    = var.ses_create_bounce_rate_alarm
  bounce_rate_threshold       = 5
  create_complaint_rate_alarm = var.ses_create_complaint_rate_alarm
  complaint_rate_threshold    = 0.1

  alarm_actions = []

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
    Component   = "ses-email-service"
  }
}

# Outputs for SES
output "ses_email_identities" {
  description = "Map of verified email identities"
  value       = module.ses.email_identities
}

output "ses_identity_arn" {
  description = "ARN of the SES email identity"
  value       = length(module.ses.email_identities) > 0 ? "arn:aws:ses:${var.region}:${data.aws_caller_identity.current.account_id}:identity/${var.ses_email_address}" : null
}

output "ses_configuration_set_name" {
  description = "Name of the SES configuration set"
  value       = module.ses.configuration_set_name
}

output "ses_configuration_set_arn" {
  description = "ARN of the SES configuration set"
  value       = module.ses.configuration_set_arn
}

output "ses_bounce_topic_arn" {
  description = "ARN of the bounce notifications SNS topic"
  value       = module.ses.bounce_topic_arn
}

output "ses_complaint_topic_arn" {
  description = "ARN of the complaint notifications SNS topic"
  value       = module.ses.complaint_topic_arn
}

output "ses_log_group_name" {
  description = "CloudWatch log group name for SES"
  value       = module.ses.log_group_name
}

output "ses_log_group_arn" {
  description = "CloudWatch log group ARN for SES"
  value       = module.ses.log_group_arn
}

output "ses_sending_role_arn" {
  description = "ARN of the IAM role for sending emails"
  value       = module.ses.sending_role_arn
}

output "ses_sending_role_name" {
  description = "Name of the IAM role for sending emails"
  value       = module.ses.sending_role_name
}

output "ses_alarm_arns" {
  description = "Map of CloudWatch alarm ARNs"
  value       = module.ses.alarm_arns
}

output "ses_config" {
  description = "Complete SES configuration for application integration"
  value       = module.ses.ses_config
}

output "ses_lambda_environment_variables" {
  description = "Environment variables for Lambda functions using SES"
  value       = module.ses.lambda_environment_variables
}
