
variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "force_delete" {
  description = "If true, will delete the repository even if it contains images"
  type        = bool
  default     = false
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type to use for the repository"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be either AES256 or KMS."
  }
}

variable "kms_key_id" {
  description = "The KMS key ID to use for encryption (only required if encryption_type is KMS)"
  type        = string
  default     = null
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy for the repository"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to keep"
  type        = number
  default     = 10
}

variable "untagged_image_days" {
  description = "Number of days to keep untagged images"
  type        = number
  default     = 7
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to the ECR repository"
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
  description = "Additional tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}
