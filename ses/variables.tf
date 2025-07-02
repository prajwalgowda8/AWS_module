
variable "domain_name" {
  description = "Domain name for SES"
  type        = string
}

variable "mail_from_domain" {
  description = "Mail from domain for SES"
  type        = string
  default     = null
}

variable "create_configuration_set" {
  description = "Create SES configuration set"
  type        = bool
  default     = true
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

variable "enable_cloudwatch_destination" {
  description = "Enable CloudWatch event destination"
  type        = bool
  default     = true
}

variable "cloudwatch_matching_types" {
  description = "List of matching types for CloudWatch destination"
  type        = list(string)
  default     = ["send", "reject", "bounce", "complaint", "delivery"]
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all SES resources"
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
  description = "Additional tags to apply to all SES resources"
  type        = map(string)
  default     = {}
}
