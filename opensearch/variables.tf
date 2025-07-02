
variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
}

variable "engine_version" {
  description = "OpenSearch engine version"
  type        = string
  default     = "OpenSearch_2.3"
}

variable "instance_type" {
  description = "Instance type for OpenSearch nodes"
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 1
}

variable "dedicated_master_enabled" {
  description = "Enable dedicated master nodes"
  type        = bool
  default     = false
}

variable "master_instance_type" {
  description = "Instance type for dedicated master nodes"
  type        = string
  default     = "t3.small.search"
}

variable "master_instance_count" {
  description = "Number of dedicated master nodes"
  type        = number
  default     = 3
}

variable "zone_awareness_enabled" {
  description = "Enable zone awareness"
  type        = bool
  default     = false
}

variable "availability_zone_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}

variable "ebs_enabled" {
  description = "Enable EBS volumes"
  type        = bool
  default     = true
}

variable "volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["standard", "gp2", "gp3", "io1"], var.volume_type)
    error_message = "Volume type must be one of: standard, gp2, gp3, io1."
  }
}

variable "volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 20
}

variable "iops" {
  description = "IOPS for io1 volumes"
  type        = number
  default     = null
}

variable "encrypt_at_rest" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "node_to_node_encryption" {
  description = "Enable node-to-node encryption"
  type        = bool
  default     = true
}

variable "enforce_https" {
  description = "Enforce HTTPS"
  type        = bool
  default     = true
}

variable "tls_security_policy" {
  description = "TLS security policy"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "vpc_id" {
  description = "VPC ID for the OpenSearch domain"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the OpenSearch domain"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of security group IDs allowed to access OpenSearch"
  type        = list(string)
  default     = []
}

variable "advanced_security_enabled" {
  description = "Enable advanced security options"
  type        = bool
  default     = false
}

variable "anonymous_auth_enabled" {
  description = "Enable anonymous authentication"
  type        = bool
  default     = false
}

variable "internal_user_database_enabled" {
  description = "Enable internal user database"
  type        = bool
  default     = false
}

variable "master_user_name" {
  description = "Master user name for advanced security"
  type        = string
  default     = null
}

variable "master_user_password" {
  description = "Master user password for advanced security"
  type        = string
  default     = null
  sensitive   = true
}

variable "enable_slow_logs" {
  description = "Enable slow logs"
  type        = bool
  default     = false
}

variable "enable_application_logs" {
  description = "Enable application logs"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "automated_snapshot_start_hour" {
  description = "Hour to start automated snapshots"
  type        = number
  default     = 23
}

variable "access_policies" {
  description = "IAM policy document for domain access"
  type        = string
  default     = null
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all OpenSearch resources"
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
  description = "Additional tags to apply to all OpenSearch resources"
  type        = map(string)
  default     = {}
}
