
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "sc-s3-demo"
}

variable "force_destroy" {
  description = "Boolean that indicates all objects should be deleted from the bucket when the bucket is destroyed"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "encryption_algorithm" {
  description = "Server-side encryption algorithm to use"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "Encryption algorithm must be either AES256 or aws:kms."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (required when encryption_algorithm is aws:kms)"
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "Enable S3 bucket public access block"
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "lifecycle_enabled" {
  description = "Enable lifecycle configuration for the S3 bucket"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the S3 bucket"
  type = list(object({
    id     = string
    status = string
    expiration = optional(object({
      days = number
    }))
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }))
    transition = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = []
}

variable "notification_enabled" {
  description = "Enable S3 bucket notifications"
  type        = bool
  default     = false
}

variable "eventbridge_enabled" {
  description = "Enable EventBridge notifications for the S3 bucket"
  type        = bool
  default     = false
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
