
variable "service_name" {
  description = "Name of the SES service"
  type        = string
  default     = "sc-ses-emailservice-demo"
}

variable "service_description" {
  description = "Description of the SES email service"
  type        = string
  default     = "SES email service for sc-ses-emailservice-demo"
}

# Email Configuration
variable "email_addresses" {
  description = "List of email addresses to verify with SES"
  type        = list(string)
  default     = ["cicloudforteaimlnotifications@unisys.com"]
}

variable "domain_name" {
  description = "Domain name for SES (optional, if managing domain identity)"
  type        = string
  default     = null
}

variable "mail_from_domain" {
  description = "Mail from domain for SES"
  type        = string
  default     = null
}

# Configuration Set
variable "create_configuration_set" {
  description = "Create SES configuration set"
  type        = bool
  default     = true
}

variable "configuration_set_name" {
  description = "Name of the SES configuration set"
  type        = string
  default     = null
}

variable "tls_policy" {
  description = "TLS policy for SES"
  type        = string
  default     = "Require"
  validation {
    condition     = contains(["Require", "Optional"], var.tls_policy)
    error_message = "TLS policy must be either Require or Optional."
  }
}

variable "reputation_metrics_enabled" {
  description = "Enable reputation metrics"
  type        = bool
  default     = true
}

variable "sending_enabled" {
  description = "Enable sending for the configuration set"
  type        = bool
  default     = true
}

# Event Destinations
variable "enable_cloudwatch_destination" {
  description = "Enable CloudWatch event destination"
  type        = bool
  default     = true
}

variable "enable_sns_destination" {
  description = "Enable SNS event destination"
  type        = bool
  default     = false
}

variable "enable_kinesis_destination" {
  description = "Enable Kinesis Firehose event destination"
  type        = bool
  default     = false
}

variable "cloudwatch_matching_types" {
  description = "List of matching types for CloudWatch destination"
  type        = list(string)
  default     = ["send", "reject", "bounce", "complaint", "delivery", "open", "click"]
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for event destination"
  type        = string
  default     = null
}

variable "kinesis_firehose_arn" {
  description = "ARN of Kinesis Firehose for event destination"
  type        = string
  default     = null
}

variable "kinesis_iam_role_arn" {
  description = "ARN of IAM role for Kinesis Firehose"
  type        = string
  default     = null
}

# Logging Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "log_kms_key_id" {
  description = "KMS key ID for CloudWatch log encryption"
  type        = string
  default     = null
}

# Identity Policies
variable "create_sending_policy" {
  description = "Create IAM policy for sending emails"
  type        = bool
  default     = true
}

variable "allowed_senders" {
  description = "List of IAM principals allowed to send emails"
  type        = list(string)
  default     = []
}

variable "custom_identity_policies" {
  description = "Map of custom identity policies"
  type = map(object({
    name   = string
    policy = string
  }))
  default = {}
}

# Bounce and Complaint Handling
variable "enable_bounce_topic" {
  description = "Enable SNS topic for bounce notifications"
  type        = bool
  default     = true
}

variable "enable_complaint_topic" {
  description = "Enable SNS topic for complaint notifications"
  type        = bool
  default     = true
}

variable "bounce_topic_name" {
  description = "Name of SNS topic for bounce notifications"
  type        = string
  default     = null
}

variable "complaint_topic_name" {
  description = "Name of SNS topic for complaint notifications"
  type        = string
  default     = null
}

# Email Templates
variable "email_templates" {
  description = "Map of email templates to create"
  type = map(object({
    subject_part = string
    text_part    = optional(string)
    html_part    = optional(string)
  }))
  default = {}
}

# Suppression List
variable "enable_account_level_suppression" {
  description = "Enable account-level suppression list"
  type        = bool
  default     = true
}

variable "suppressed_reasons" {
  description = "List of reasons for suppression"
  type        = list(string)
  default     = ["BOUNCE", "COMPLAINT"]
  validation {
    condition = alltrue([
      for reason in var.suppressed_reasons : contains(["BOUNCE", "COMPLAINT"], reason)
    ])
    error_message = "Suppressed reasons must be BOUNCE or COMPLAINT."
  }
}

# Dedicated IP Configuration
variable "create_dedicated_ip_pool" {
  description = "Create dedicated IP pool"
  type        = bool
  default     = false
}

variable "dedicated_ip_pool_name" {
  description = "Name of the dedicated IP pool"
  type        = string
  default     = null
}

variable "dedicated_ip_warmup_enabled" {
  description = "Enable dedicated IP warmup"
  type        = bool
  default     = true
}

# Contact List (for SESv2)
variable "create_contact_list" {
  description = "Create SES contact list"
  type        = bool
  default     = false
}

variable "contact_list_name" {
  description = "Name of the contact list"
  type        = string
  default     = null
}

variable "contact_list_description" {
  description = "Description of the contact list"
  type        = string
  default     = "Contact list for email campaigns"
}

# Monitoring and Alerting
variable "create_sending_quota_alarm" {
  description = "Create CloudWatch alarm for sending quota"
  type        = bool
  default     = true
}

variable "sending_quota_threshold" {
  description = "Threshold for sending quota alarm (percentage)"
  type        = number
  default     = 80
  validation {
    condition     = var.sending_quota_threshold >= 0 && var.sending_quota_threshold <= 100
    error_message = "Sending quota threshold must be between 0 and 100."
  }
}

variable "create_bounce_rate_alarm" {
  description = "Create CloudWatch alarm for bounce rate"
  type        = bool
  default     = true
}

variable "bounce_rate_threshold" {
  description = "Threshold for bounce rate alarm (percentage)"
  type        = number
  default     = 5
  validation {
    condition     = var.bounce_rate_threshold >= 0 && var.bounce_rate_threshold <= 100
    error_message = "Bounce rate threshold must be between 0 and 100."
  }
}

variable "create_complaint_rate_alarm" {
  description = "Create CloudWatch alarm for complaint rate"
  type        = bool
  default     = true
}

variable "complaint_rate_threshold" {
  description = "Threshold for complaint rate alarm (percentage)"
  type        = number
  default     = 0.1
  validation {
    condition     = var.complaint_rate_threshold >= 0 && var.complaint_rate_threshold <= 100
    error_message = "Complaint rate threshold must be between 0 and 100."
  }
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms trigger"
  type        = list(string)
  default     = []
}

# Mandatory tag variables
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "contact_group" {
  description = "Contact group for the resources"
  type        = string
}

variable "contact_name" {
  description = "Contact name for the resources"
  type        = string
}

variable "cost_bucket" {
  description = "Cost bucket for the resources"
  type        = string
}

variable "data_owner" {
  description = "Data owner for the resources"
  type        = string
}

variable "display_name" {
  description = "Display name for the resources"
  type        = string
}

variable "environment" {
  description = "Environment for the resources"
  type        = string
}

variable "has_public_ip" {
  description = "Whether the resources have public IP"
  type        = string
}

variable "has_unisys_network_connection" {
  description = "Whether the resources have Unisys network connection"
  type        = string
}

variable "service_line" {
  description = "Service line for the resources"
  type        = string
}
