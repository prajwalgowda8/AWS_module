
# SES Variables
variable "ses_service_name" {
  description = "Name of the SES service"
  type        = string
}

variable "ses_email_address" {
  description = "Email address to verify with SES"
  type        = string
}

variable "ses_create_configuration_set" {
  description = "Create SES configuration set"
  type        = bool
  default     = true
}

variable "ses_tls_policy" {
  description = "TLS policy for SES"
  type        = string
  default     = "Require"
}

variable "ses_reputation_metrics_enabled" {
  description = "Enable reputation metrics"
  type        = bool
  default     = true
}

variable "ses_enable_cloudwatch_destination" {
  description = "Enable CloudWatch event destination"
  type        = bool
  default     = true
}

variable "ses_enable_bounce_topic" {
  description = "Enable SNS topic for bounce notifications"
  type        = bool
  default     = true
}

variable "ses_enable_complaint_topic" {
  description = "Enable SNS topic for complaint notifications"
  type        = bool
  default     = true
}

variable "ses_log_retention_days" {
  description = "CloudWatch log retention in days for SES"
  type        = number
  default     = 30
}

variable "ses_create_sending_quota_alarm" {
  description = "Create CloudWatch alarm for sending quota"
  type        = bool
  default     = true
}

variable "ses_create_bounce_rate_alarm" {
  description = "Create CloudWatch alarm for bounce rate"
  type        = bool
  default     = true
}

variable "ses_create_complaint_rate_alarm" {
  description = "Create CloudWatch alarm for complaint rate"
  type        = bool
  default     = true
}
