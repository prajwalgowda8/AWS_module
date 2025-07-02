
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Local tags configuration
locals {
  mandatory_tags = merge(var.common_tags, {
    contactGroup                = var.contact_group
    contactName                 = var.contact_name
    costBucket                  = var.cost_bucket
    dataOwner                   = var.data_owner
    displayName                 = var.display_name
    environment                 = var.environment
    hasPublicIP                 = var.has_public_ip
    hasUnisysNetworkConnection  = var.has_unisys_network_connection
    serviceLine                 = var.service_line
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# SNS Topic for CloudWatch Alarms
resource "aws_sns_topic" "cloudwatch_alerts" {
  count = var.create_sns_topic ? 1 : 0

  name         = "${var.service_name}-cloudwatch-alerts"
  display_name = "CloudWatch Alerts for ${var.service_name}"

  kms_master_key_id = var.sns_kms_key_id
  
  delivery_policy = jsonencode({
    "http" = {
      "defaultHealthyRetryPolicy" = {
        "minDelayTarget"     = 20
        "maxDelayTarget"     = 20
        "numRetries"         = 3
        "numMaxDelayRetries" = 0
        "numMinDelayRetries" = 0
        "numNoDelayRetries"  = 0
        "backoffFunction"    = "linear"
      }
      "disableSubscriptionOverrides" = false
    }
  })

  tags = merge(
    local.mandatory_tags,
    {
      Name    = "${var.service_name}-cloudwatch-alerts"
      Purpose = "CloudWatch monitoring alerts"
    }
  )
}

# SNS Topic Subscriptions
resource "aws_sns_topic_subscription" "email_alerts" {
  count = var.create_sns_topic && length(var.alert_email_addresses) > 0 ? length(var.alert_email_addresses) : 0

  topic_arn = aws_sns_topic.cloudwatch_alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email_addresses[count.index]
}

resource "aws_sns_topic_subscription" "sms_alerts" {
  count = var.create_sns_topic && length(var.alert_phone_numbers) > 0 ? length(var.alert_phone_numbers) : 0

  topic_arn = aws_sns_topic.cloudwatch_alerts[0].arn
  protocol  = "sms"
  endpoint  = var.alert_phone_numbers[count.index]
}

resource "aws_sns_topic_subscription" "lambda_alerts" {
  count = var.create_sns_topic && var.alert_lambda_function_arn != null ? 1 : 0

  topic_arn = aws_sns_topic.cloudwatch_alerts[0].arn
  protocol  = "lambda"
  endpoint  = var.alert_lambda_function_arn
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application_logs" {
  for_each = var.log_groups

  name              = each.value.name
  retention_in_days = each.value.retention_days
  kms_key_id        = each.value.kms_key_id
  log_group_class   = each.value.log_class

  tags = merge(
    local.mandatory_tags,
    each.value.tags,
    {
      Name    = each.value.name
      Purpose = "Log group for ${var.service_name}"
    }
  )
}

# Log Metric Filters
resource "aws_cloudwatch_log_metric_filter" "custom_metrics" {
  for_each = var.log_metric_filters

  name           = each.value.name
  log_group_name = each.value.log_group_name
  pattern        = each.value.pattern

  metric_transformation {
    name          = each.value.metric_name
    namespace     = each.value.metric_namespace
    value         = each.value.metric_value
    default_value = each.value.default_value
    unit          = each.value.unit
  }

  depends_on = [aws_cloudwatch_log_group.application_logs]
}

# CloudWatch Dashboards
resource "aws_cloudwatch_dashboard" "infrastructure_dashboard" {
  count = var.create_infrastructure_dashboard ? 1 : 0

  dashboard_name = "${var.service_name}-infrastructure"

  dashboard_body = jsonencode({
    widgets = concat(
      # EC2 Widgets
      var.enable_ec2_monitoring ? [
        {
          type   = "metric"
          x      = 0
          y      = 0
          width  = 12
          height = 6
          properties = {
            metrics = [
              ["AWS/EC2", "CPUUtilization"],
              [".", "NetworkIn"],
              [".", "NetworkOut"],
              [".", "DiskReadOps"],
              [".", "DiskWriteOps"]
            ]
            view    = "timeSeries"
            stacked = false
            region  = data.aws_region.current.name
            title   = "EC2 Instance Metrics - ${var.service_name}"
            period  = 300
          }
        }
      ] : [],
      # RDS Widgets
      var.enable_rds_monitoring ? [
        {
          type   = "metric"
          x      = 0
          y      = 6
          width  = 12
          height = 6
          properties = {
            metrics = [
              ["AWS/RDS", "CPUUtilization"],
              [".", "DatabaseConnections"],
              [".", "ReadLatency"],
              [".", "WriteLatency"],
              [".", "FreeableMemory"]
            ]
            view    = "timeSeries"
            stacked = false
            region  = data.aws_region.current.name
            title   = "RDS Database Metrics - ${var.service_name}"
            period  = 300
          }
        }
      ] : [],
      # Lambda Widgets
      var.enable_lambda_monitoring ? [
        {
          type   = "metric"
          x      = 0
          y      = 12
          width  = 12
          height = 6
          properties = {
            metrics = [
              ["AWS/Lambda", "Invocations"],
              [".", "Duration"],
              [".", "Errors"],
              [".", "Throttles"],
              [".", "ConcurrentExecutions"]
            ]
            view    = "timeSeries"
            stacked = false
            region  = data.aws_region.current.name
            title   = "Lambda Function Metrics - ${var.service_name}"
            period  = 300
          }
        }
      ] : [],
      # EKS Widgets
      var.enable_eks_monitoring ? [
        {
          type   = "metric"
          x      = 0
          y      = 18
          width  = 12
          height = 6
          properties = {
            metrics = [
              ["AWS/EKS", "cluster_failed_request_count"],
              [".", "cluster_request_total"]
            ]
            view    = "timeSeries"
            stacked = false
            region  = data.aws_region.current.name
            title   = "EKS Cluster Metrics - ${var.service_name}"
            period  = 300
          }
        }
      ] : [],
      # Custom Widgets
      [
        for widget in var.custom_dashboard_widgets : {
          type       = widget.type
          x          = widget.x
          y          = widget.y
          width      = widget.width
          height     = widget.height
          properties = widget.properties
        }
      ]
    )
  })
}

# Application-specific Dashboard
resource "aws_cloudwatch_dashboard" "application_dashboard" {
  count = var.create_application_dashboard ? 1 : 0

  dashboard_name = "${var.service_name}-application"

  dashboard_body = jsonencode({
    widgets = [
      for widget in var.application_dashboard_widgets : {
        type       = widget.type
        x          = widget.x
        y          = widget.y
        width      = widget.width
        height     = widget.height
        properties = widget.properties
      }
    ]
  })
}

# CloudWatch Metric Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_cpu_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors EC2 CPU utilization for ${var.service_name}"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.cloudwatch_alerts[0].arn] : var.external_alarm_actions

  dimensions = var.cpu_alarm_dimensions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-high-cpu-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  count = var.enable_memory_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-high-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.memory_alarm_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = var.memory_alarm_period
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_description   = "This metric monitors memory utilization for ${var.service_name}"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.cloudwatch_alerts[0].arn] : var.external_alarm_actions

  dimensions = var.memory_alarm_dimensions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-high-memory-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "disk_space" {
  count = var.enable_disk_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-low-disk-space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.disk_alarm_evaluation_periods
  metric_name         = "disk_free"
  namespace           = "CWAgent"
  period              = var.disk_alarm_period
  statistic           = "Average"
  threshold           = var.disk_alarm_threshold
  alarm_description   = "This metric monitors available disk space for ${var.service_name}"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.cloudwatch_alerts[0].arn] : var.external_alarm_actions

  dimensions = var.disk_alarm_dimensions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-low-disk-space-alarm"
    }
  )
}

# Database-specific Alarms
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  count = var.enable_rds_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.rds_cpu_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.rds_cpu_period
  statistic           = "Average"
  threshold           = var.rds_cpu_threshold
  alarm_description   = "This metric monitors RDS CPU utilization for ${var.service_name}"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.cloudwatch_alerts[0].arn] : var.external_alarm_actions

  dimensions = var.rds_alarm_dimensions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-rds-high-cpu-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  count = var.enable_rds_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.rds_connections_evaluation_periods
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = var.rds_connections_period
  statistic           = "Average"
  threshold           = var.rds_connections_threshold
  alarm_description   = "This metric monitors RDS database connections for ${var.service_name}"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.cloudwatch_alerts[0].arn] : var.external_alarm_actions

  dimensions = var.rds_alarm_dimensions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-rds-high-connections-alarm"
    }
  )
}

# Lambda-specific Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = var.enable_lambda_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.lambda_error_evaluation_periods
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = var.lambda_error_period
  statistic           = "Sum"
  threshold           = var.lambda_error_threshold
  alarm_description   = "This metric monitors Lambda function errors for ${var.service_name}"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.cloudwatch_alerts[0].arn] : var.external_alarm_actions

  dimensions = var.lambda_alarm_dimensions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-lambda-errors-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  count = var.enable_lambda_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.lambda_duration_evaluation_periods
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = var.lambda_duration_period
  statistic           = "Average"
  threshold           = var.lambda_duration_threshold
  alarm_description   = "This metric monitors Lambda function duration for ${var.service_name}"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.cloudwatch_alerts[0].arn] : var.external_alarm_actions

  dimensions = var.lambda_alarm_dimensions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-lambda-duration-alarm"
    }
  )
}

# Custom Metric Alarms
resource "aws_cloudwatch_metric_alarm" "custom_alarms" {
  for_each = var.custom_metric_alarms

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.description
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.cloudwatch_alerts[0].arn] : var.external_alarm_actions

  dimensions                = each.value.dimensions
  datapoints_to_alarm      = each.value.datapoints_to_alarm
  treat_missing_data       = each.value.treat_missing_data
  insufficient_data_actions = each.value.insufficient_data_actions
  ok_actions               = each.value.ok_actions

  tags = merge(
    local.mandatory_tags,
    each.value.tags,
    {
      Name = each.value.alarm_name
    }
  )
}

# Composite Alarms
resource "aws_cloudwatch_composite_alarm" "application_health" {
  count = var.create_composite_alarm ? 1 : 0

  alarm_name        = "${var.service_name}-application-health"
  alarm_description = "Composite alarm for overall application health of ${var.service_name}"
  alarm_rule        = var.composite_alarm_rule

  actions_enabled = true
  alarm_actions   = var.create_sns_topic ? [aws_sns_topic.cloudwatch_alerts[0].arn] : var.external_alarm_actions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-application-health-composite"
    }
  )
}

# CloudWatch Events Rules
resource "aws_cloudwatch_event_rule" "scheduled_health_check" {
  count = var.create_scheduled_health_check ? 1 : 0

  name                = "${var.service_name}-scheduled-health-check"
  description         = "Scheduled health check for ${var.service_name}"
  schedule_expression = var.health_check_schedule

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-scheduled-health-check"
    }
  )
}

resource "aws_cloudwatch_event_target" "health_check_target" {
  count = var.create_scheduled_health_check && var.health_check_lambda_arn != null ? 1 : 0

  rule      = aws_cloudwatch_event_rule.scheduled_health_check[0].name
  target_id = "HealthCheckLambdaTarget"
  arn       = var.health_check_lambda_arn
}

# CloudWatch Insights Queries (stored as parameters for easy access)
resource "aws_ssm_parameter" "cloudwatch_insights_queries" {
  for_each = var.cloudwatch_insights_queries

  name  = "/cloudwatch/insights/${var.service_name}/${each.key}"
  type  = "String"
  value = each.value

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-insights-${each.key}"
    }
  )
}
