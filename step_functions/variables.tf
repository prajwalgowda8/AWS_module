
variable "state_machine_name" {
  description = "Name of the Step Functions state machine"
  type        = string
}

variable "definition" {
  description = "Amazon States Language definition of the state machine"
  type        = string
}

variable "type" {
  description = "Type of state machine (STANDARD or EXPRESS)"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "EXPRESS"], var.type)
    error_message = "Type must be either STANDARD or EXPRESS."
  }
}

variable "additional_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the Step Functions role"
  type        = list(string)
  default     = []
}

variable "custom_policy" {
  description = "Custom IAM policy document for the Step Functions role"
  type        = string
  default     = null
}

variable "enable_logging" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = false
}

variable "log_level" {
  description = "Log level for CloudWatch logging"
  type        = string
  default     = "ERROR"
  validation {
    condition     = contains(["ALL", "ERROR", "FATAL", "OFF"], var.log_level)
    error_message = "Log level must be one of: ALL, ERROR, FATAL, OFF."
  }
}

variable "include_execution_data" {
  description = "Include execution data in CloudWatch logs"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "enable_tracing" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = false
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all Step Functions resources"
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
  description = "Additional tags to apply to all Step Functions resources"
  type        = map(string)
  default     = {}
}
