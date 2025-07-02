
variable "cluster_identifier" {
  description = "Identifier for the DocumentDB cluster"
  type        = string
}

variable "engine_version" {
  description = "DocumentDB engine version"
  type        = string
  default     = "4.0.0"
}

variable "master_username" {
  description = "Master username for the DocumentDB cluster"
  type        = string
  default     = "docdbadmin"
}

variable "instance_class" {
  description = "Instance class for DocumentDB instances"
  type        = string
  default     = "db.t3.medium"
}

variable "instance_count" {
  description = "Number of instances in the DocumentDB cluster"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "VPC ID where the DocumentDB cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DocumentDB subnet group"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of security group IDs allowed to access DocumentDB"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "List of availability zones for the DocumentDB cluster"
  type        = list(string)
  default     = null
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Daily backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Weekly maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = ["audit", "profiler"]
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "KMS key ID for Performance Insights"
  type        = string
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all DocumentDB resources"
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
  description = "Additional tags to apply to all DocumentDB resources"
  type        = map(string)
  default     = {}
}
