
# CloudWatch Monitoring Configuration
module "cloudwatch" {
  source = "${local.module_source}cloudwatch"

  # Service Configuration
  service_name        = var.cloudwatch_service_name
  service_description = "CloudWatch monitoring and logging components for ${var.cloudwatch_service_name}"

  # SNS Configuration
  create_sns_topic        = var.cloudwatch_create_sns_topic
  alert_email_addresses   = var.cloudwatch_alert_email_addresses
  alert_phone_numbers     = []
  alert_lambda_function_arn = null
  external_alarm_actions  = []

  # Log Groups Configuration
  log_groups = {
    primary = {
      name           = var.cloudwatch_log_group_name
      retention_days = var.cloudwatch_log_retention_days
      kms_key_id     = null
      log_class      = "STANDARD"
      tags           = {}
    }
    application = {
      name           = "/aws/application/${var.cloudwatch_service_name}"
      retention_days = var.cloudwatch_log_retention_days
      kms_key_id     = null
      log_class      = "STANDARD"
      tags           = {}
    }
    system = {
      name           = "/aws/system/${var.cloudwatch_service_name}"
      retention_days = 14
      kms_key_id     = null
      log_class      = "STANDARD"
      tags           = {}
    }
  }

  # Log Metric Filters
  log_metric_filters = {
    error_count = {
      name             = "ErrorCount"
      log_group_name   = var.cloudwatch_log_group_name
      pattern          = "[timestamp, request_id, ERROR]"
      metric_name      = "ErrorCount"
      metric_namespace = "Application/Errors"
      metric_value     = "1"
      unit             = "Count"
    }
    warning_count = {
      name             = "WarningCount"
      log_group_name   = var.cloudwatch_log_group_name
      pattern          = "[timestamp, request_id, WARN]"
      metric_name      = "WarningCount"
      metric_namespace = "Application/Warnings"
      metric_value     = "1"
      unit             = "Count"
    }
  }

  # Dashboard Configuration
  create_infrastructure_dashboard = var.cloudwatch_create_infrastructure_dashboard
  create_application_dashboard    = var.cloudwatch_create_application_dashboard

  # Service Monitoring
  enable_ec2_monitoring    = true
  enable_rds_monitoring    = true
  enable_lambda_monitoring = true
  enable_eks_monitoring    = true

  # Custom Dashboard Widgets (empty by default)
  custom_dashboard_widgets     = []
  application_dashboard_widgets = []

  # Alarm Configuration
  enable_cpu_alarms    = var.cloudwatch_enable_cpu_alarms
  enable_memory_alarms = var.cloudwatch_enable_memory_alarms
  enable_disk_alarms   = var.cloudwatch_enable_disk_alarms
  enable_rds_alarms    = false
  enable_lambda_alarms = false

  # Alarm Thresholds
  cpu_alarm_threshold    = 80
  memory_alarm_threshold = 80
  disk_alarm_threshold   = 10

  # Alarm Evaluation Periods
  cpu_alarm_evaluation_periods    = 2
  memory_alarm_evaluation_periods = 2
  disk_alarm_evaluation_periods   = 2

  # Alarm Periods
  cpu_alarm_period    = 300
  memory_alarm_period = 300
  disk_alarm_period   = 300

  # Alarm Dimensions (empty by default)
  cpu_alarm_dimensions    = {}
  memory_alarm_dimensions = {}
  disk_alarm_dimensions   = {}

  # Custom Metric Alarms (empty by default)
  custom_metric_alarms = {}

  # Composite Alarm Configuration
  create_composite_alarm = false
  composite_alarm_rule   = ""

  # Scheduled Health Check
  create_scheduled_health_check = false
  health_check_schedule         = "rate(5 minutes)"
  health_check_lambda_arn       = null

  # CloudWatch Insights Queries
  cloudwatch_insights_queries = {
    error_analysis = <<-EOT
      fields @timestamp, @message
      | filter @message like /ERROR/
      | sort @timestamp desc
      | limit 100
    EOT
    
    performance_analysis = <<-EOT
      fields @timestamp, @duration
      | filter @type = "REPORT"
      | stats avg(@duration), max(@duration), min(@duration) by bin(5m)
    EOT
    
    request_analysis = <<-EOT
      fields @timestamp, @requestId, @message
      | filter @message like /START RequestId/
      | stats count() by bin(5m)
    EOT
  }

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
    Component   = "cloudwatch-monitoring"
  }
}

# Outputs for CloudWatch
output "cloudwatch_sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alerts"
  value       = module.cloudwatch.sns_topic_arn
}

output "cloudwatch_sns_topic_name" {
  description = "Name of the SNS topic for CloudWatch alerts"
  value       = module.cloudwatch.sns_topic_name
}

output "cloudwatch_infrastructure_dashboard_url" {
  description = "URL of the infrastructure monitoring dashboard"
  value       = module.cloudwatch.infrastructure_dashboard_url
}

output "cloudwatch_application_dashboard_url" {
  description = "URL of the application monitoring dashboard"
  value       = module.cloudwatch.application_dashboard_url
}

output "cloudwatch_log_groups" {
  description = "Map of created log groups"
  value       = module.cloudwatch.log_groups
}

output "cloudwatch_log_group_names" {
  description = "List of log group names"
  value       = module.cloudwatch.log_group_names
}

output "cloudwatch_log_group_arns" {
  description = "List of log group ARNs"
  value       = module.cloudwatch.log_group_arns
}

output "cloudwatch_cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = module.cloudwatch.cpu_alarm_arn
}

output "cloudwatch_memory_alarm_arn" {
  description = "ARN of the memory utilization alarm"
  value       = module.cloudwatch.memory_alarm_arn
}

output "cloudwatch_disk_alarm_arn" {
  description = "ARN of the disk space alarm"
  value       = module.cloudwatch.disk_alarm_arn
}

output "cloudwatch_monitoring_config" {
  description = "Complete monitoring configuration summary"
  value       = module.cloudwatch.monitoring_config
}
