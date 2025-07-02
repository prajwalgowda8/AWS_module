
variable "database_name" {
  description = "Name of the Glue catalog database"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Glue jobs"
  type        = string
}

variable "glue_jobs" {
  description = "Map of Glue job configurations"
  type = map(object({
    description         = string
    script_location     = string
    glue_version       = string
    python_version     = string
    worker_type        = string
    number_of_workers  = number
    max_concurrent_runs = number
    max_retries        = number
    timeout            = number
    default_arguments  = map(string)
  }))
  default = {}
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all Glue resources"
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
  description = "Additional tags to apply to all Glue resources"
  type        = map(string)
  default     = {}
}
