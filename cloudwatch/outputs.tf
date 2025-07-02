
output "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alerts"
  value       = var.create_sns_topic ? aws_sns_topic.cloudwatch_alerts[0].arn : null
}

output "sns_topic_name" {
  description = "Name of the SNS topic for CloudWatch alerts"
  value       = var.create_sns_topic ? aws_sns_topic.cloudwatch_alerts[0].name : null
}

output "infrastructure_dashboard_url" {
  description = "URL of the infrastructure monitoring dashboard"
  value       = var.create_infrastructure_dashboard ? "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.infrastructure_dashboard[0].dashboard_name}" : null
}

output "application_dashboard_url" {
  description = "URL of the application monitoring dashboard"
  value       = var.create_application_dashboard ? "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.application_dashboard[0].dashboard_name}" : null
}

output "infrastructure_dashboard_name" {
  description = "Name of the infrastructure monitoring dashboard"
  value       = var.create_infrastructure_dashboard ? aws_cloudwatch_dashboard.infrastructure_dashboard[0].dashboard_name : null
}

output "application_dashboard_name" {
  description = "Name of the application monitoring dashboard"
  value       = var.create_application_dashboard ? aws_cloudwatch_dashboard.application_dashboard[0].dashboard_name : null
}

output "log_groups" {
  description = "Map of created log groups"
  value = {
    for k, v in aws_cloudwatch_log_group.application_logs : k => {
      name = v.name
      arn  = v.arn
    }
  }
}

output "log_group_names" {
  description = "List of log group names"
  value       = [for lg in aws_cloudwatch_log_group.application_logs : lg.name]
}

output "log_group_arns" {
  description = "List of log group ARNs"
  value       = [for lg in aws_cloudwatch_log_group.application_logs : lg.arn]
}

output "metric_filters" {
  description = "Map of created metric filters"
  value = {
    for k, v in aws_cloudwatch_log_metric_filter.custom_metrics : k => {
      name           = v.name
      log_group_name = v.log_group_name
      pattern        = v.pattern
    }
  }
}

output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = var.enable_cpu_alarms ? aws_cloudwatch_metric_alarm.high_cpu[0].arn : null
}

output "memory_alarm_arn" {
  description = "ARN of the memory utilization alarm"
  value       = var.enable_memory_alarms ? aws_cloudwatch_metric_alarm.high_memory[0].arn : null
}

output "disk_alarm_arn" {
  description = "ARN of the disk space alarm"
  value       = var.enable_disk_alarms ? aws_cloudwatch_metric_alarm.disk_space[0].arn : null
}

output "rds_cpu_alarm_arn" {
  description = "ARN of the RDS CPU alarm"
  value       = var.enable_rds_alarms ? aws_cloudwatch_metric_alarm.rds_cpu[0].arn : null
}

output "rds_connections_alarm_arn" {
  description = "ARN of the RDS connections alarm"
  value       = var.enable_rds_alarms ? aws_cloudwatch_metric_alarm.rds_connections[0].arn : null
}

output "lambda_errors_alarm_arn" {
  description = "ARN of the Lambda errors alarm"
  value       = var.enable_lambda_alarms ? aws_cloudwatch_metric_alarm.lambda_errors[0].arn : null
}

output "lambda_duration_alarm_arn" {
  description = "ARN of the Lambda duration alarm"
  value       = var.enable_lambda_alarms ? aws_cloudwatch_metric_alarm.lambda_duration[0].arn : null
}

output "custom_alarms" {
  description = "Map of custom alarm ARNs"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.custom_alarms : k => {
      arn  = v.arn
      name = v.alarm_name
    }
  }
}

output "composite_alarm_arn" {
  description = "ARN of the composite alarm"
  value       = var.create_composite_alarm ? aws_cloudwatch_composite_alarm.application_health[0].arn : null
}

output "health_check_rule_arn" {
  description = "ARN of the scheduled health check rule"
  value       = var.create_scheduled_health_check ? aws_cloudwatch_event_rule.scheduled_health_check[0].arn : null
}

output "health_check_rule_name" {
  description = "Name of the scheduled health check rule"
  value       = var.create_scheduled_health_check ? aws_cloudwatch_event_rule.scheduled_health_check[0].name : null
}

output "insights_queries" {
  description = "Map of CloudWatch Insights query parameter names"
  value = {
    for k, v in aws_ssm_parameter.cloudwatch_insights_queries : k => v.name
  }
}

output "monitoring_config" {
  description = "Complete monitoring configuration summary"
  value = {
    service_name              = var.service_name
    region                    = data.aws_region.current.name
    sns_topic_arn            = var.create_sns_topic ? aws_sns_topic.cloudwatch_alerts[0].arn : null
    infrastructure_dashboard  = var.create_infrastructure_dashboard ? aws_cloudwatch_dashboard.infrastructure_dashboard[0].dashboard_name : null
    application_dashboard    = var.create_application_dashboard ? aws_cloudwatch_dashboard.application_dashboard[0].dashboard_name : null
    log_groups_count        = length(aws_cloudwatch_log_group.application_logs)
    metric_filters_count    = length(aws_cloudwatch_log_metric_filter.custom_metrics)
    custom_alarms_count     = length(aws_cloudwatch_metric_alarm.custom_alarms)
    composite_alarm_enabled = var.create_composite_alarm
    health_check_enabled    = var.create_scheduled_health_check
  }
}

output "alert_config" {
  description = "Alert configuration details"
  value = {
    sns_topic_created       = var.create_sns_topic
    email_subscribers_count = length(var.alert_email_addresses)
    sms_subscribers_count   = length(var.alert_phone_numbers)
    lambda_integration      = var.alert_lambda_function_arn != null
    external_actions_count  = length(var.external_alarm_actions)
  }
}

output "dashboard_config" {
  description = "Dashboard configuration details"
  value = {
    infrastructure_dashboard_enabled = var.create_infrastructure_dashboard
    application_dashboard_enabled    = var.create_application_dashboard
    ec2_monitoring_enabled          = var.enable_ec2_monitoring
    rds_monitoring_enabled          = var.enable_rds_monitoring
    lambda_monitoring_enabled       = var.enable_lambda_monitoring
    eks_monitoring_enabled          = var.enable_eks_monitoring
    custom_widgets_count            = length(var.custom_dashboard_widgets)
    application_widgets_count       = length(var.application_dashboard_widgets)
  }
}

output "alarm_config" {
  description = "Alarm configuration summary"
  value = {
    cpu_alarms_enabled      = var.enable_cpu_alarms
    memory_alarms_enabled   = var.enable_memory_alarms
    disk_alarms_enabled     = var.enable_disk_alarms
    rds_alarms_enabled      = var.enable_rds_alarms
    lambda_alarms_enabled   = var.enable_lambda_alarms
    custom_alarms_count     = length(var.custom_metric_alarms)
    composite_alarm_enabled = var.create_composite_alarm
    
    thresholds = {
      cpu_threshold              = var.cpu_alarm_threshold
      memory_threshold           = var.memory_alarm_threshold
      disk_threshold            = var.disk_alarm_threshold
      rds_cpu_threshold         = var.rds_cpu_threshold
      rds_connections_threshold = var.rds_connections_threshold
      lambda_error_threshold    = var.lambda_error_threshold
      lambda_duration_threshold = var.lambda_duration_threshold
    }
  }
}

output "log_config" {
  description = "Log configuration summary"
  value = {
    log_groups = {
      for k, v in var.log_groups : k => {
        name           = v.name
        retention_days = v.retention_days
        log_class      = v.log_class
        kms_encrypted  = v.kms_key_id != null
      }
    }
    
    metric_filters = {
      for k, v in var.log_metric_filters : k => {
        name             = v.name
        log_group_name   = v.log_group_name
        metric_namespace = v.metric_namespace
        metric_name      = v.metric_name
      }
    }
    
    insights_queries_count = length(var.cloudwatch_insights_queries)
  }
}

output "integration_config" {
  description = "Configuration for integration with other AWS services"
  value = {
    sns_topic_arn    = var.create_sns_topic ? aws_sns_topic.cloudwatch_alerts[0].arn : null
    log_group_arns   = [for lg in aws_cloudwatch_log_group.application_logs : lg.arn]
    dashboard_names  = compact([
      var.create_infrastructure_dashboard ? aws_cloudwatch_dashboard.infrastructure_dashboard[0].dashboard_name : null,
      var.create_application_dashboard ? aws_cloudwatch_dashboard.application_dashboard[0].dashboard_name : null
    ])
    alarm_arns = compact([
      var.enable_cpu_alarms ? aws_cloudwatch_metric_alarm.high_cpu[0].arn : null,
      var.enable_memory_alarms ? aws_cloudwatch_metric_alarm.high_memory[0].arn : null,
      var.enable_disk_alarms ? aws_cloudwatch_metric_alarm.disk_space[0].arn : null,
      var.enable_rds_alarms ? aws_cloudwatch_metric_alarm.rds_cpu[0].arn : null,
      var.enable_rds_alarms ? aws_cloudwatch_metric_alarm.rds_connections[0].arn : null,
      var.enable_lambda_alarms ? aws_cloudwatch_metric_alarm.lambda_errors[0].arn : null,
      var.enable_lambda_alarms ? aws_cloudwatch_metric_alarm.lambda_duration[0].arn : null
    ])
    custom_alarm_arns = [for alarm in aws_cloudwatch_metric_alarm.custom_alarms : alarm.arn]
  }
}

output "cost_optimization" {
  description = "Cost optimization recommendations for CloudWatch"
  value = {
    log_retention_optimization = {
      for k, v in var.log_groups : k => {
        current_retention = v.retention_days
        recommendation   = v.retention_days > 30 ? "Consider reducing retention to 30 days for cost savings" : "Retention period is optimized"
        estimated_savings = v.retention_days > 30 ? "Up to 50% reduction in log storage costs" : "No immediate savings available"
      }
    }
    
    dashboard_optimization = {
      widget_count = length(var.custom_dashboard_widgets) + length(var.application_dashboard_widgets)
      recommendation = length(var.custom_dashboard_widgets) + length(var.application_dashboard_widgets) > 50 ? "Consider consolidating widgets to reduce dashboard complexity" : "Dashboard complexity is within recommended limits"
    }
    
    alarm_optimization = {
      total_alarms = length(aws_cloudwatch_metric_alarm.custom_alarms) + (var.enable_cpu_alarms ? 1 : 0) + (var.enable_memory_alarms ? 1 : 0) + (var.enable_disk_alarms ? 1 : 0) + (var.enable_rds_alarms ? 2 : 0) + (var.enable_lambda_alarms ? 2 : 0)
      recommendation = "Monitor alarm usage and remove unused alarms to optimize costs"
    }
  }
}
