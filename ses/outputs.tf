
output "email_identities" {
  description = "Map of verified email identities"
  value       = { for k, v in aws_ses_email_identity.email_addresses : k => v.email }
}

output "domain_identity_arn" {
  description = "ARN of the SES domain identity"
  value       = var.domain_name != null ? aws_ses_domain_identity.domain[0].arn : null
}

output "domain_identity_verification_token" {
  description = "Verification token for the SES domain identity"
  value       = var.domain_name != null ? aws_ses_domain_identity.domain[0].verification_token : null
}

output "dkim_tokens" {
  description = "DKIM tokens for the domain"
  value       = var.domain_name != null ? aws_ses_domain_dkim.domain_dkim[0].dkim_tokens : null
}

output "configuration_set_name" {
  description = "Name of the SES configuration set"
  value       = var.create_configuration_set ? aws_ses_configuration_set.main[0].name : null
}

output "configuration_set_arn" {
  description = "ARN of the SES configuration set"
  value       = var.create_configuration_set ? aws_ses_configuration_set.main[0].arn : null
}

output "mail_from_domain" {
  description = "Mail from domain"
  value       = var.domain_name != null && var.mail_from_domain != null ? aws_ses_domain_mail_from.domain_mail_from[0].mail_from_domain : null
}

output "bounce_topic_arn" {
  description = "ARN of the bounce notifications SNS topic"
  value       = var.enable_bounce_topic ? aws_sns_topic.bounce_notifications[0].arn : null
}

output "complaint_topic_arn" {
  description = "ARN of the complaint notifications SNS topic"
  value       = var.enable_complaint_topic ? aws_sns_topic.complaint_notifications[0].arn : null
}

output "log_group_name" {
  description = "CloudWatch log group name for SES"
  value       = var.enable_cloudwatch_destination ? aws_cloudwatch_log_group.ses_logs[0].name : null
}

output "log_group_arn" {
  description = "CloudWatch log group ARN for SES"
  value       = var.enable_cloudwatch_destination ? aws_cloudwatch_log_group.ses_logs[0].arn : null
}

output "sending_role_arn" {
  description = "ARN of the IAM role for sending emails"
  value       = var.create_sending_policy && length(var.allowed_senders) == 0 ? aws_iam_role.ses_sending_role[0].arn : null
}

output "sending_role_name" {
  description = "Name of the IAM role for sending emails"
  value       = var.create_sending_policy && length(var.allowed_senders) == 0 ? aws_iam_role.ses_sending_role[0].name : null
}

output "dedicated_ip_pool_name" {
  description = "Name of the dedicated IP pool"
  value       = var.create_dedicated_ip_pool ? aws_sesv2_dedicated_ip_pool.main[0].pool_name : null
}

output "contact_list_name" {
  description = "Name of the SES contact list"
  value       = var.create_contact_list ? aws_sesv2_contact_list.main[0].contact_list_name : null
}

output "email_templates" {
  description = "Map of created email templates"
  value       = { for k, v in aws_ses_template.email_templates : k => v.name }
}

output "alarm_arns" {
  description = "Map of CloudWatch alarm ARNs"
  value = {
    sending_quota_alarm  = var.create_sending_quota_alarm ? aws_cloudwatch_metric_alarm.sending_quota[0].arn : null
    bounce_rate_alarm    = var.create_bounce_rate_alarm ? aws_cloudwatch_metric_alarm.bounce_rate[0].arn : null
    complaint_rate_alarm = var.create_complaint_rate_alarm ? aws_cloudwatch_metric_alarm.complaint_rate[0].arn : null
  }
}

output "receipt_rule_set_name" {
  description = "Name of the SES receipt rule set"
  value       = var.domain_name != null ? aws_ses_receipt_rule_set.main[0].rule_set_name : null
}

# Configuration outputs for application integration
output "ses_config" {
  description = "Complete SES configuration for application integration"
  value = {
    service_name           = var.service_name
    region                = data.aws_region.current.name
    account_id            = data.aws_caller_identity.current.account_id
    email_addresses       = var.email_addresses
    domain_name           = var.domain_name
    configuration_set_name = var.create_configuration_set ? aws_ses_configuration_set.main[0].name : null
    sending_role_arn      = var.create_sending_policy && length(var.allowed_senders) == 0 ? aws_iam_role.ses_sending_role[0].arn : null
    bounce_topic_arn      = var.enable_bounce_topic ? aws_sns_topic.bounce_notifications[0].arn : null
    complaint_topic_arn   = var.enable_complaint_topic ? aws_sns_topic.complaint_notifications[0].arn : null
    log_group_name        = var.enable_cloudwatch_destination ? aws_cloudwatch_log_group.ses_logs[0].name : null
  }
}

# Security configuration
output "security_config" {
  description = "Security configuration for SES"
  value = {
    tls_policy                    = var.tls_policy
    reputation_metrics_enabled    = var.reputation_metrics_enabled
    account_suppression_enabled   = var.enable_account_level_suppression
    suppressed_reasons           = var.suppressed_reasons
    bounce_notifications_enabled = var.enable_bounce_topic
    complaint_notifications_enabled = var.enable_complaint_topic
  }
}

# Monitoring configuration
output "monitoring_config" {
  description = "Monitoring configuration for SES"
  value = {
    cloudwatch_destination_enabled = var.enable_cloudwatch_destination
    log_group_name                = var.enable_cloudwatch_destination ? aws_cloudwatch_log_group.ses_logs[0].name : null
    log_retention_days            = var.log_retention_days
    sending_quota_alarm_enabled   = var.create_sending_quota_alarm
    bounce_rate_alarm_enabled     = var.create_bounce_rate_alarm
    complaint_rate_alarm_enabled  = var.create_complaint_rate_alarm
    sending_quota_threshold       = var.sending_quota_threshold
    bounce_rate_threshold         = var.bounce_rate_threshold
    complaint_rate_threshold      = var.complaint_rate_threshold
  }
}

# Email template configuration
output "template_config" {
  description = "Email template configuration"
  value = {
    templates_created = length(var.email_templates)
    template_names    = keys(var.email_templates)
  }
}

# Domain configuration
output "domain_config" {
  description = "Domain configuration for SES"
  value = var.domain_name != null ? {
    domain_name           = var.domain_name
    domain_identity_arn   = aws_ses_domain_identity.domain[0].arn
    verification_token    = aws_ses_domain_identity.domain[0].verification_token
    dkim_tokens          = aws_ses_domain_dkim.domain_dkim[0].dkim_tokens
    mail_from_domain     = var.mail_from_domain
    receipt_rules_enabled = true
  } : null
}

# Integration outputs for Lambda functions
output "lambda_environment_variables" {
  description = "Environment variables for Lambda functions using SES"
  value = {
    SES_REGION             = data.aws_region.current.name
    SES_CONFIGURATION_SET  = var.create_configuration_set ? aws_ses_configuration_set.main[0].name : ""
    SES_FROM_EMAIL         = var.email_addresses[0]
    SES_DOMAIN             = var.domain_name != null ? var.domain_name : ""
    SES_BOUNCE_TOPIC_ARN   = var.enable_bounce_topic ? aws_sns_topic.bounce_notifications[0].arn : ""
    SES_COMPLAINT_TOPIC_ARN = var.enable_complaint_topic ? aws_sns_topic.complaint_notifications[0].arn : ""
  }
}

# Cost optimization outputs
output "cost_optimization" {
  description = "Cost optimization recommendations for SES"
  value = {
    dedicated_ip_pool_enabled = var.create_dedicated_ip_pool
    log_retention_days       = var.log_retention_days
    monitoring_enabled       = var.enable_cloudwatch_destination
    recommendations = {
      use_shared_ips          = "Use shared IPs for lower volume sending to reduce costs"
      optimize_log_retention  = "Adjust log retention based on compliance requirements"
      monitor_bounce_rates    = "Keep bounce rates low to maintain good reputation"
      use_templates          = "Use email templates for consistent formatting and reduced errors"
    }
  }
}

# Compliance and governance outputs
output "compliance_config" {
  description = "Compliance and governance configuration"
  value = {
    mandatory_tags_applied    = true
    bounce_handling_enabled   = var.enable_bounce_topic
    complaint_handling_enabled = var.enable_complaint_topic
    suppression_list_enabled  = var.enable_account_level_suppression
    tls_required             = var.tls_policy == "Require"
    logging_enabled          = var.enable_cloudwatch_destination
    monitoring_enabled       = var.create_sending_quota_alarm || var.create_bounce_rate_alarm || var.create_complaint_rate_alarm
  }
}
