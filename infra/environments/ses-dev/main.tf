
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
  project     = "sc-ses-emailservice-demo"
  
  # Common tags for all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedDate = "2025-01-02"
  }
}

# SNS topic for SES alarms
resource "aws_sns_topic" "ses_alarms" {
  name = "${local.project}-ses-alarms"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project}-ses-alarms"
    }
  )
}

# SNS topic subscription for email alerts
resource "aws_sns_topic_subscription" "ses_alarm_email" {
  topic_arn = aws_sns_topic.ses_alarms.arn
  protocol  = "email"
  endpoint  = "cicloudforteaimlnotifications@unisys.com"
}

# SES Module
module "ses" {
  source = "../../ses"
  
  # Service configuration
  service_name        = "sc-ses-emailservice-demo"
  service_description = "SES email service for sc-ses-emailservice-demo"
  
  # Email configuration
  email_addresses = ["cicloudforteaimlnotifications@unisys.com"]
  
  # Configuration set
  create_configuration_set = true
  tls_policy              = "Require"
  reputation_metrics_enabled = true
  sending_enabled         = true
  
  # Event destinations
  enable_cloudwatch_destination = true
  enable_sns_destination        = false
  enable_kinesis_destination    = false
  
  cloudwatch_matching_types = [
    "send",
    "reject", 
    "bounce",
    "complaint",
    "delivery",
    "open",
    "click"
  ]
  
  # Logging configuration
  log_retention_days = 30
  
  # Bounce and complaint handling
  enable_bounce_topic    = true
  enable_complaint_topic = true
  
  # Identity policies
  create_sending_policy = true
  allowed_senders      = []  # Will create IAM role instead
  
  # Email templates for common use cases
  email_templates = {
    welcome_email = {
      subject_part = "Welcome to {{company_name}}"
      text_part    = "Welcome to {{company_name}}! Thank you for joining us."
      html_part    = "<h1>Welcome to {{company_name}}!</h1><p>Thank you for joining us.</p>"
    }
    notification_email = {
      subject_part = "{{notification_type}} - {{subject}}"
      text_part    = "{{message}}"
      html_part    = "<div><h2>{{notification_type}}</h2><p>{{message}}</p></div>"
    }
    alert_email = {
      subject_part = "ALERT: {{alert_type}}"
      text_part    = "Alert: {{alert_message}}\n\nTime: {{timestamp}}\nSeverity: {{severity}}"
      html_part    = "<div style='color: red;'><h2>ALERT: {{alert_type}}</h2><p><strong>{{alert_message}}</strong></p><p>Time: {{timestamp}}<br>Severity: {{severity}}</p></div>"
    }
  }
  
  # Suppression list
  enable_account_level_suppression = true
  suppressed_reasons              = ["BOUNCE", "COMPLAINT"]
  
  # Monitoring and alerting
  create_sending_quota_alarm  = true
  sending_quota_threshold     = 80
  
  create_bounce_rate_alarm    = true
  bounce_rate_threshold       = 5
  
  create_complaint_rate_alarm = true
  complaint_rate_threshold    = 0.1
  
  alarm_actions = [aws_sns_topic.ses_alarms.arn]
  
  # Dedicated IP (disabled for dev environment)
  create_dedicated_ip_pool = false
  
  # Contact list (disabled for dev environment)
  create_contact_list = false
  
  # Mandatory tags
  common_tags                    = local.common_tags
  contact_group                  = "Email Services Team"
  contact_name                   = "Lisa Chen"
  cost_bucket                    = "development"
  data_owner                     = "Communications Team"
  display_name                   = "SC SES Email Service Demo Development"
  environment                    = local.environment
  has_public_ip                  = "false"
  has_unisys_network_connection  = "true"
  service_line                   = "Communication Services"
}

# Output SES information
output "email_identities" {
  description = "Map of verified email identities"
  value       = module.ses.email_identities
}

output "configuration_set_name" {
  description = "Name of the SES configuration set"
  value       = module.ses.configuration_set_name
}

output "configuration_set_arn" {
  description = "ARN of the SES configuration set"
  value       = module.ses.configuration_set_arn
}

output "bounce_topic_arn" {
  description = "ARN of the bounce notifications SNS topic"
  value       = module.ses.bounce_topic_arn
}

output "complaint_topic_arn" {
  description = "ARN of the complaint notifications SNS topic"
  value       = module.ses.complaint_topic_arn
}

output "log_group_name" {
  description = "CloudWatch log group name for SES"
  value       = module.ses.log_group_name
}

output "sending_role_arn" {
  description = "ARN of the IAM role for sending emails"
  value       = module.ses.sending_role_arn
}

output "email_templates" {
  description = "Map of created email templates"
  value       = module.ses.email_templates
}

output "alarm_arns" {
  description = "Map of CloudWatch alarm ARNs"
  value       = module.ses.alarm_arns
}

output "ses_config" {
  description = "Complete SES configuration for application integration"
  value       = module.ses.ses_config
}

output "security_config" {
  description = "Security configuration for SES"
  value       = module.ses.security_config
}

output "monitoring_config" {
  description = "Monitoring configuration for SES"
  value       = module.ses.monitoring_config
}

output "lambda_environment_variables" {
  description = "Environment variables for Lambda functions using SES"
  value       = module.ses.lambda_environment_variables
}

output "compliance_config" {
  description = "Compliance and governance configuration"
  value       = module.ses.compliance_config
}

output "sns_alarm_topic_arn" {
  description = "ARN of the SNS topic for SES alarms"
  value       = aws_sns_topic.ses_alarms.arn
}
