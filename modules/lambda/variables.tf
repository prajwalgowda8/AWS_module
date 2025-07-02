
variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

# Code configuration
variable "filename" {
  description = "Path to the function's deployment package within the local filesystem"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the function's deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the deployment package object"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "Object version of the deployment package"
  type        = string
  default     = null
}

variable "image_uri" {
  description = "ECR image URI containing the function's deployment package"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the package file"
  type        = string
  default     = null
}

# Runtime configuration
variable "package_type" {
  description = "Lambda deployment package type"
  type        = string
  default     = "Zip"
  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "Package type must be either Zip or Image."
  }
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.11"
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
  default     = "index.handler"
}

variable "architectures" {
  description = "Instruction set architecture"
  type        = list(string)
  default     = ["x86_64"]
  validation {
    condition = alltrue([
      for arch in var.architectures : contains(["x86_64", "arm64"], arch)
    ])
    error_message = "Architectures must be either x86_64 or arm64."
  }
}

# Performance configuration
variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 and 10240 MB."
  }
}

variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 3
  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "ephemeral_storage_size" {
  description = "Amount of Ephemeral storage (/tmp) to allocate for the Lambda Function in MB"
  type        = number
  default     = null
  validation {
    condition = var.ephemeral_storage_size == null || (
      var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240
    )
    error_message = "Ephemeral storage size must be between 512 and 10240 MB."
  }
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function"
  type        = number
  default     = -1
}

# Environment variables
variable "environment_variables" {
  description = "Map of environment variables"
  type        = map(string)
  default     = null
}

# VPC configuration
variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type = object({
    vpc_id             = string
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# Dead letter configuration
variable "dead_letter_config" {
  description = "Dead letter queue configuration"
  type = object({
    target_arn = string
  })
  default = null
}

# Tracing configuration
variable "tracing_config" {
  description = "X-Ray tracing configuration"
  type = object({
    mode = string
  })
  default = null
  validation {
    condition = var.tracing_config == null || contains(["Active", "PassThrough"], var.tracing_config.mode)
    error_message = "Tracing mode must be either Active or PassThrough."
  }
}

# Layers
variable "layers" {
  description = "List of Lambda Layer Version ARNs"
  type        = list(string)
  default     = []
}

# Security
variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt environment variables"
  type        = string
  default     = null
}

# Additional IAM policies
variable "additional_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

# Publishing
variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version"
  type        = bool
  default     = false
}

# Logging
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "log_kms_key_id" {
  description = "KMS key ID for CloudWatch log encryption"
  type        = string
  default     = null
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all Lambda resources"
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
  description = "Additional tags to apply to all Lambda resources"
  type        = map(string)
  default     = {}
}
