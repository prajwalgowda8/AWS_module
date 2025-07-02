
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
  project     = "sc-cw-monitoring-demo"
  
  # Common tags for all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedDate = "2025-01-02"
  }
}

# CloudWatch Module
module "cloudwatch" {
  source = "../../cloudwatch"
  
  # Service configuration
  service_name        = "sc-cw-monitoring-demo"
  service_description = "CloudWatch monitoring and logging components for sc-cw-monitoring-demo"
  
  # SNS configuration for alerts
  create_sns_topic      = true
  alert_email_addresses = ["admin@example.com", "devops@example.com"]
  alert_phone_numbers   = ["+1234567890"]
  
  # Log groups configuration
  log_groups = {
    application = {
      name           = "/aws/application/sc-cw-monitoring-demo"
      retention_days = 30
      log_class      = "STANDARD"
    }
    system = {
      name           = "/aws/system/sc-cw-monitoring-demo"
      retention_days = 14
      log_class      = "STANDARD"
    }
    security = {
      name           = "/aws/security/sc-cw-monitoring-demo"
      retention_days = 90
      log_class      = "STANDARD"
    }
    lambda = {
      name           = "/aws/lambda/sc-cw-monitoring-demo"
      retention_days = 30
      log_class      = "STANDARD"
    }
    api_gateway = {
      name           = "/aws/apigateway/sc-cw-monitoring-demo"
      retention_days = 30
      log_class      = "STANDARD"
    }
  }
  
  # Log metric filters for monitoring
  log_metric_filters = {
    error_count = {
      name             = "ErrorCount"
      log_group_name   = "/aws/application/sc-cw-monitoring-demo"
      pattern          = "[timestamp, request_id, ERROR]"
      metric_name      = "ErrorCount"
      metric_namespace = "Application/Errors"
      unit             = "Count"
    }
    warning_count = {
      name             = "WarningCount"
      log_group_name   = "/aws/application/sc-cw-monitoring-demo"
      pattern          = "[timestamp, request_id, WARN]"
      metric_name      = "WarningCount"
      metric_namespace = "Application/Warnings"
      unit             = "Count"
    }
    security_events = {
      name             = "SecurityEvents"
      log_group_name   = "/aws/security/sc-cw-monitoring-demo"
      pattern          = "[timestamp, event_type=\"SECURITY\", ...]"
      metric_name      = "SecurityEvents"
      metric_namespace = "Security/Events"
      unit             = "Count"
    }
    lambda_errors = {
      name             = "LambdaErrors"
      log_group_name   = "/aws/lambda/sc-cw-monitoring-demo"
      pattern          = "[timestamp, request_id, \"ERROR\"]"
      metric_name      = "LambdaErrors"
      metric_namespace = "Lambda/Errors"
      unit             = "Count"
    }
  }
  
  # Dashboard configuration
  create_infrastructure_dashboard = true
  create_application_dashboard    = true
  
  # Enable monitoring for different services
  enable_ec2_monitoring    = true
  enable_rds_monitoring    = true
  enable_lambda_monitoring = true
  enable_eks_monitoring    = false
  
  # Custom dashboard widgets for application monitoring
  application_dashboard_widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 12
      height = 6
      properties = {
        metrics = [
          ["Application/Errors", "ErrorCount"],
          ["Application/Warnings", "WarningCount"],
          ["Security/Events", "SecurityEvents"],
          ["Lambda/Errors", "LambdaErrors"]
        ]
        view    = "timeSeries"
        stacked = false
        region  = "us-east-1"
        title   = "Application Metrics - ${local.project}"
        period  = 300
      }
    },
    {
      type   = "log"
      x      = 0
      y      = 6
      width  = 24
      height = 6
      properties = {
        query   = "SOURCE '/aws/application/sc-cw-monitoring-demo' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20"
        region  = "us-east-1"
        title   = "Recent Application Errors"
        view    = "table"
      }
    }
  ]
  
  # Alarm configuration
  enable_cpu_alarms    = true
  cpu_alarm_threshold  = 80
  cpu_alarm_dimensions = {
    InstanceId = "i-1234567890abcdef0"
  }
  
  enable_memory_alarms    = true
  memory_alarm_threshold  = 85
  memory_alarm_dimensions = {
    InstanceId = "i-1234567890abcdef0"
  }
  
  enable_disk_alarms    = true
  disk_alarm_threshold  = 10
  disk_alarm_dimensions = {
    InstanceId = "i-1234567890abcdef0"
    device     = "/dev/xvda1"
    fstype     = "ext4"
    path       = "/"
  }
  
  enable_rds_alarms         = true
  rds_cpu_threshold         = 75
  rds_connections_threshold = 80
  rds_alarm_dimensions = {
    DBInstanceIdentifier = "sc-rds-postgres-demo"
  }
  
  enable_lambda_alarms         = true
  lambda_error_threshold       = 5
  lambda_duration_threshold    = 30000
  lambda_alarm_dimensions = {
    FunctionName = "sc-lambda-function"
  }
  
  # Custom metric alarms
  custom_metric_alarms = {
    high_error_rate = {
      alarm_name          = "${local.project}-high-error-rate"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "ErrorCount"
      namespace           = "Application/Errors"
      period              = 300
      statistic           = "Sum"
      threshold           = 10
      description         = "High error rate detected in application"
      dimensions = {
        Environment = local.environment
      }
      treat_missing_data = "notBreaching"
    }
    security_alert = {
      alarm_name          = "${local.project}-security-events"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "SecurityEvents"
      namespace           = "Security/Events"
      period              = 300
      statistic           = "Sum"
      threshold           = 0
      description         = "Security events detected"
      dimensions = {
        Environment = local.environment
      }
      treat_missing_data = "notBreaching"
    }
  }
  
  # Composite alarm for overall health
  create_composite_alarm = true
  composite_alarm_rule   = "ALARM(${local.project}-high-error-rate) OR ALARM(${local.project}-security-events) OR ALARM(${local.project}-high-cpu-utilization)"
  
  # Scheduled health check
  create_scheduled_health_check = true
  health_check_schedule         = "rate(5 minutes)"
  
  # CloudWatch Insights queries
  cloudwatch_insights_queries = {
    error_analysis = <<-EOT
      fields @timestamp, @message, @requestId
      | filter @message like /ERROR/
      | sort @timestamp desc
      | limit 100
    EOT
    
    performance_analysis = <<-EOT
      fields @timestamp, @duration, @billedDuration, @memorySize, @maxMemoryUsed
      | filter @type = "REPORT"
      | stats avg(@duration), max(@duration), min(@duration) by bin(5m)
      | sort @timestamp desc
    EOT
    
    request_analysis = <<-EOT
      fields @timestamp, @requestId, @message
      | filter @message like /START RequestId/
      | stats count() by bin(5m)
      | sort @timestamp desc
    EOT
    
    security_analysis = <<-EOT
      fields @timestamp, @message
      | filter @message like /SECURITY/
      | sort @timestamp desc
      | limit 50
    EOT
    
    lambda_cold_starts = <<-EOT
      fields @timestamp, @type, @requestId, @duration
      | filter @message like /INIT_START/
      | stats count() by bin(1h)
      | sort @timestamp desc
    EOT
  }
  
  # Mandatory tags
  common_tags                    = local.common_tags
  contact_group                  = "Monitoring Team"
  contact_name                   = "Robert Kim"
  cost_bucket                    = "development"
  data_owner                     = "Operations Team"
  display_name                   = "SC CloudWatch Monitoring Demo Development"
  environment                    = local.environment
  has_public_ip                  = "false"
  has_unisys_network_connection  = "false"
  service_line                   = "Monitoring Services"
}

# Output CloudWatch information
output "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alerts"
  value       = module.cloudwatch.sns_topic_arn
}

output "infrastructure_dashboard_url" {
  description = "URL of the infrastructure monitoring dashboard"
  value       = module.cloudwatch.infrastructure_dashboard_url
}

output "application_dashboard_url" {
  description = "URL of the application monitoring dashboard"
  value       = module.cloudwatch.application_dashboard_url
}

output "log_groups" {
  description = "Map of created log groups"
  value       = module.cloudwatch.log_groups
}

output "log_group_names" {
  description = "List of log group names"
  value       = module.cloudwatch.log_group_names
}

output "metric_filters" {
  description = "Map of created metric filters"
  value       = module.cloudwatch.metric_filters
}

output "alarm_arns" {
  description = "Map of alarm ARNs"
  value = {
    cpu_alarm               = module.cloudwatch.cpu_alarm_arn
    memory_alarm           = module.cloudwatch.memory_alarm_arn
    disk_alarm             = module.cloudwatch.disk_alarm_arn
    rds_cpu_alarm          = module.cloudwatch.rds_cpu_alarm_arn
    rds_connections_alarm  = module.cloudwatch.rds_connections_alarm_arn
    lambda_errors_alarm    = module.cloudwatch.lambda_errors_alarm_arn
    lambda_duration_alarm  = module.cloudwatch.lambda_duration_alarm_arn
    composite_alarm        = module.cloudwatch.composite_alarm_arn
  }
}

output "custom_alarms" {
  description = "Map of custom alarm ARNs"
  value       = module.cloudwatch.custom_alarms
}

output "health_check_rule_arn" {
  description = "ARN of the scheduled health check rule"
  value       = module.cloudwatch.health_check_rule_arn
}

output "insights_queries" {
  description = "Map of CloudWatch Insights query parameter names"
  value       = module.cloudwatch.insights_queries
}

output "monitoring_config" {
  description = "Complete monitoring configuration summary"
  value       = module.cloudwatch.monitoring_config
}

output "alert_config" {
  description = "Alert configuration details"
  value       = module.cloudwatch.alert_config
}

output "dashboard_config" {
  description = "Dashboard configuration details"
  value       = module.cloudwatch.dashboard_config
}

output "alarm_config" {
  description = "Alarm configuration summary"
  value       = module.cloudwatch.alarm_config
}

output "log_config" {
  description = "Log configuration summary"
  value       = module.cloudwatch.log_config
}

output "integration_config" {
  description = "Configuration for integration with other AWS services"
  value       = module.cloudwatch.integration_config
}

output "cost_optimization" {
  description = "Cost optimization recommendations for CloudWatch"
  value       = module.cloudwatch.cost_optimization
}
