
variable "trail_name" {
  description = "Name of the CloudTrail"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
}

variable "s3_key_prefix" {
  description = "S3 key prefix for CloudTrail logs"
  type        = string
  default     = "cloudtrail-logs"
}

variable "enable_log_file_validation" {
  description = "Enable log file integrity validation"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging for the trail"
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Include global service events"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Whether the trail is created in all regions"
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Whether the trail is an AWS Organizations trail"
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN for CloudTrail logs"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "KMS key ID for encrypting CloudTrail logs"
  type        = string
  default     = null
}

variable "event_selectors" {
  description = "List of event selectors for data events"
  type = list(object({
    read_write_type                   = string
    include_management_events         = bool
    exclude_management_event_sources = list(string)
    data_resources = list(object({
      type   = string
      values = list(string)
    }))
  }))
  default = []
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all CloudTrail resources"
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
  description = "Additional tags to apply to all CloudTrail resources"
  type        = map(string)
  default     = {}
}
