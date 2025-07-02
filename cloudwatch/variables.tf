
variable "service_name" {
  description = "Name of the service for CloudWatch monitoring"
  type        = string
}

# SNS Configuration
variable "create_sns_topic" {
  description = "Create SNS topic for CloudWatch alerts"
  type        = bool
  default     = true
}

variable "sns_kms_key_id" {
  description = "KMS key ID for SNS topic encryption"
  type        = string
  default     = null
}

variable "alert_email_addresses" {
  description = "List of email addresses to receive CloudWatch alerts"
  type        = list(string)
  default     = []
}

variable "alert_phone_numbers" {
  description = "List of phone numbers to receive SMS alerts"
  type        = list(string)
  default     = []
}

variable "alert_lambda_function_arn" {
  description = "ARN of Lambda function to receive alerts"
  type        = string
  default     = null
}

variable "external_alarm_actions" {
  description = "External alarm actions if not using created SNS topic"
  type        = list(string)
  default     = []
}

# Log Groups Configuration
variable "log_groups" {
  description = "Map of log groups to create"
  type = map(object({
    name           = string
    retention_days = number
    kms_key_id     = optional(string)
    log_class      = optional(string, "STANDARD")
    tags           = optional(map(string), {})
  }))
  default = {}
}

# Log Metric Filters
variable "log_metric_filters" {
  description = "Map of log metric filters to create"
  type = map(object({
    name             = string
    log_group_name   = string
    pattern          = string
    metric_name      = string
    metric_namespace = string
    metric_value     = optional(string, "1")
    default_value    = optional(string)
    unit             = optional(string, "Count")
  }))
  default = {}
}

# Dashboard Configuration
variable "create_infrastructure_dashboard" {
  description = "Create infrastructure monitoring dashboard"
  type        = bool
  default     = true
}

variable "create_application_dashboard" {
  description = "Create application-specific dashboard"
  type        = bool
  default     = false
}

variable "enable_ec2_monitoring" {
  description = "Enable EC2 monitoring in infrastructure dashboard"
  type        = bool
  default     = true
}

variable "enable_rds_monitoring" {
  description = "Enable RDS monitoring in infrastructure dashboard"
  type        = bool
  default     = true
}

variable "enable_lambda_monitoring" {
  description = "Enable Lambda monitoring in infrastructure dashboard"
  type        = bool
  default     = true
}

variable "enable_eks_monitoring" {
  description = "Enable EKS monitoring in infrastructure dashboard"
  type        = bool
  default     = false
}

variable "custom_dashboard_widgets" {
  description = "List of custom widgets for infrastructure dashboard"
  type = list(object({
    type       = string
    x          = number
    y          = number
    width      = number
    height     = number
    properties = any
  }))
  default = []
}

variable "application_dashboard_widgets" {
  description = "List of widgets for application dashboard"
  type = list(object({
    type       = string
    x          = number
    y          = number
    width      = number
    height     = number
    properties = any
  }))
  default = []
}

# CPU Alarm Configuration
variable "enable_cpu_alarms" {
  description = "Enable CPU utilization alarms"
  type        = bool
  default     = true
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for alarm"
  type        = number
  default     = 80
  validation {
    condition     = var.cpu_alarm_threshold >= 0 && var.cpu_alarm_threshold <= 100
    error_message = "CPU alarm threshold must be between 0 and 100."
  }
}

variable "cpu_alarm_evaluation_periods" {
  description = "Number of evaluation periods for CPU alarm"
  type        = number
  default     = 2
}

variable "cpu_alarm_period" {
  description = "Period in seconds for CPU alarm"
  type        = number
  default     = 300
}

variable "cpu_alarm_dimensions" {
  description = "Dimensions for CPU alarm"
  type        = map(string)
  default     = {}
}

# Memory Alarm Configuration
variable "enable_memory_alarms" {
  description = "Enable memory utilization alarms"
  type        = bool
  default     = true
}

variable "memory_alarm_threshold" {
  description = "Memory utilization threshold for alarm"
  type        = number
  default     = 80
  validation {
    condition     = var.memory_alarm_threshold >= 0 && var.memory_alarm_threshold <= 100
    error_message = "Memory alarm threshold must be between 0 and 100."
  }
}

variable "memory_alarm_evaluation_periods" {
  description = "Number of evaluation periods for memory alarm"
  type        = number
  default     = 2
}

variable "memory_alarm_period" {
  description = "Period in seconds for memory alarm"
  type        = number
  default     = 300
}

variable "memory_alarm_dimensions" {
  description = "Dimensions for memory alarm"
  type        = map(string)
  default     = {}
}

# Disk Alarm Configuration
variable "enable_disk_alarms" {
  description = "Enable disk space alarms"
  type        = bool
  default     = true
}

variable "disk_alarm_threshold" {
  description = "Disk space threshold for alarm (in GB)"
  type        = number
  default     = 10
}

variable "disk_alarm_evaluation_periods" {
  description = "Number of evaluation periods for disk alarm"
  type        = number
  default     = 2
}

variable "disk_alarm_period" {
  description = "Period in seconds for disk alarm"
  type        = number
  default     = 300
}

variable "disk_alarm_dimensions" {
  description = "Dimensions for disk alarm"
  type        = map(string)
  default     = {}
}

# RDS Alarm Configuration
variable "enable_rds_alarms" {
  description = "Enable RDS monitoring alarms"
  type        = bool
  default     = false
}

variable "rds_cpu_threshold" {
  description = "RDS CPU utilization threshold"
  type        = number
  default     = 80
}

variable "rds_cpu_evaluation_periods" {
  description = "Number of evaluation periods for RDS CPU alarm"
  type        = number
  default     = 2
}

variable "rds_cpu_period" {
  description = "Period in seconds for RDS CPU alarm"
  type        = number
  default     = 300
}

variable "rds_connections_threshold" {
  description = "RDS connections threshold"
  type        = number
  default     = 80
}

variable "rds_connections_evaluation_periods" {
  description = "Number of evaluation periods for RDS connections alarm"
  type        = number
  default     = 2
}

variable "rds_connections_period" {
  description = "Period in seconds for RDS connections alarm"
  type        = number
  default     = 300
}

variable "rds_alarm_dimensions" {
  description = "Dimensions for RDS alarms"
  type        = map(string)
  default     = {}
}

# Lambda Alarm Configuration
variable "enable_lambda_alarms" {
  description = "Enable Lambda monitoring alarms"
  type        = bool
  default     = false
}

variable "lambda_error_threshold" {
  description = "Lambda error count threshold"
  type        = number
  default     = 5
}

variable "lambda_error_evaluation_periods" {
  description = "Number of evaluation periods for Lambda error alarm"
  type        = number
  default     = 2
}

variable "lambda_error_period" {
  description = "Period in seconds for Lambda error alarm"
  type        = number
  default     = 300
}

variable "lambda_duration_threshold" {
  description = "Lambda duration threshold in milliseconds"
  type        = number
  default     = 30000
}

variable "lambda_duration_evaluation_periods" {
  description = "Number of evaluation periods for Lambda duration alarm"
  type        = number
  default     = 2
}

variable "lambda_duration_period" {
  description = "Period in seconds for Lambda duration alarm"
  type        = number
  default     = 300
}

variable "lambda_alarm_dimensions" {
  description = "Dimensions for Lambda alarms"
  type        = map(string)
  default     = {}
}

# Custom Metric Alarms
variable "custom_metric_alarms" {
  description = "Map of custom metric alarms to create"
  type = map(object({
    alarm_name               = string
    comparison_operator      = string
    evaluation_periods       = number
    metric_name             = string
    namespace               = string
    period                  = number
    statistic               = string
    threshold               = number
    description             = string
    dimensions              = optional(map(string), {})
    datapoints_to_alarm     = optional(number)
    treat_missing_data      = optional(string, "missing")
    insufficient_data_actions = optional(list(string), [])
    ok_actions              = optional(list(string), [])
    tags                    = optional(map(string), {})
  }))
  default = {}
}

# Composite Alarm Configuration
variable "create_composite_alarm" {
  description = "Create composite alarm for application health"
  type        = bool
  default     = false
}

variable "composite_alarm_rule" {
  description = "Rule for composite alarm"
  type        = string
  default     = ""
}

# Scheduled Health Check Configuration
variable "create_scheduled_health_check" {
  description = "Create scheduled health check using CloudWatch Events"
  type        = bool
  default     = false
}

variable "health_check_schedule" {
  description = "Schedule expression for health check"
  type        = string
  default     = "rate(5 minutes)"
}

variable "health_check_lambda_arn" {
  description = "ARN of Lambda function for health check"
  type        = string
  default     = null
}

# CloudWatch Insights Queries
variable "cloudwatch_insights_queries" {
  description = "Map of CloudWatch Insights queries"
  type        = map(string)
  default = {
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
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all CloudWatch resources"
  type        = map(string)
  validation {
    condition = alltrue([
      contains(keys(var.mandatory_tags), "Environment"),
      contains(keys(var.mandatory_tags), "Project"),
      contains(keys(var.mandatory_tags), "Owner")
    ])
    error_message = "Mandatory tags must include Environment, Project, and Owner."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to all CloudWatch resources"
  type        = map(string)
  default     = {}
}
