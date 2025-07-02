
variable "state_machine_name" {
  description = "Name of the Step Functions state machine"
  type        = string
  default     = "sc-stepfn-demo"
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
  default     = true
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
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption for the state machine"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (if not provided, AWS managed key will be used)"
  type        = string
  default     = null
}

variable "publish_version" {
  description = "Publish a version of the state machine during creation"
  type        = bool
  default     = false
}

variable "lambda_functions" {
  description = "Map of Lambda function ARNs that the state machine can invoke"
  type        = map(string)
  default     = {}
}

variable "sns_topics" {
  description = "List of SNS topic ARNs that the state machine can publish to"
  type        = list(string)
  default     = []
}

variable "sqs_queues" {
  description = "List of SQS queue ARNs that the state machine can send messages to"
  type        = list(string)
  default     = []
}

variable "s3_buckets" {
  description = "List of S3 bucket ARNs that the state machine can access"
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
