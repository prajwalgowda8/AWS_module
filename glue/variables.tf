
variable "database_name" {
  description = "Name of the Glue catalog database"
  type        = string
  default     = "sc-glue-demo"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Glue jobs and scripts"
  type        = string
}

variable "glue_version" {
  description = "Version of AWS Glue to use"
  type        = string
  default     = "5.0"
}

variable "worker_type" {
  description = "Type of predefined worker for Glue jobs"
  type        = string
  default     = "G.1X"
  validation {
    condition     = contains(["Standard", "G.1X", "G.2X", "G.025X", "Z.2X"], var.worker_type)
    error_message = "Worker type must be one of: Standard, G.1X, G.2X, G.025X, Z.2X."
  }
}

variable "number_of_workers" {
  description = "Number of workers for Glue jobs"
  type        = number
  default     = 5
}

variable "glue_jobs" {
  description = "Map of Glue job configurations"
  type = map(object({
    description         = string
    script_location     = string
    python_version      = optional(string, "3")
    max_concurrent_runs = optional(number, 1)
    max_retries         = optional(number, 0)
    timeout             = optional(number, 2880)
    default_arguments   = optional(map(string), {})
    connections         = optional(list(string), [])
  }))
  default = {}
}

variable "crawlers" {
  description = "Map of Glue crawler configurations"
  type = map(object({
    description   = string
    schedule      = optional(string, null)
    table_prefix  = optional(string, "")
    s3_targets = optional(list(object({
      path       = string
      exclusions = optional(list(string), [])
    })), [])
    jdbc_targets = optional(list(object({
      connection_name = string
      path            = string
      exclusions      = optional(list(string), [])
    })), [])
  }))
  default = {}
}

variable "connections" {
  description = "Map of Glue connection configurations"
  type = map(object({
    description         = string
    connection_type     = string
    connection_properties = map(string)
    physical_connection_requirements = optional(object({
      availability_zone      = optional(string)
      security_group_id_list = optional(list(string))
      subnet_id              = optional(string)
    }), null)
  }))
  default = {}
}

variable "enable_job_bookmarks" {
  description = "Enable job bookmarks for Glue jobs"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable CloudWatch metrics for Glue jobs"
  type        = bool
  default     = true
}

variable "enable_continuous_logging" {
  description = "Enable continuous logging for Glue jobs"
  type        = bool
  default     = true
}

variable "log_group_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 14
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
