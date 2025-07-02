
variable "index_name" {
  description = "Name of the Kendra index"
  type        = string
}

variable "index_description" {
  description = "Description of the Kendra index"
  type        = string
  default     = "Kendra search index for document search and retrieval"
}

variable "index_edition" {
  description = "Edition of the Kendra index"
  type        = string
  default     = "DEVELOPER_EDITION"
  validation {
    condition     = contains(["DEVELOPER_EDITION", "ENTERPRISE_EDITION"], var.index_edition)
    error_message = "Index edition must be either DEVELOPER_EDITION or ENTERPRISE_EDITION."
  }
}

# Capacity Configuration
variable "capacity_units" {
  description = "Capacity units for the Kendra index"
  type = object({
    query_capacity_units   = number
    storage_capacity_units = number
  })
  default = null
}

# Security Configuration
variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "user_context_policy" {
  description = "User context policy for the index"
  type        = string
  default     = null
  validation {
    condition = var.user_context_policy == null || contains([
      "ATTRIBUTE_FILTER", "USER_TOKEN"
    ], var.user_context_policy)
    error_message = "User context policy must be either ATTRIBUTE_FILTER or USER_TOKEN."
  }
}

variable "user_group_resolution_mode" {
  description = "User group resolution mode"
  type        = string
  default     = null
  validation {
    condition = var.user_group_resolution_mode == null || contains([
      "AWS_SSO", "NONE"
    ], var.user_group_resolution_mode)
    error_message = "User group resolution mode must be either AWS_SSO or NONE."
  }
}

# User Token Configuration
variable "user_token_configurations" {
  description = "User token configurations for the index"
  type = list(object({
    json_token_type_configuration = optional(object({
      user_name_attribute_field = string
      group_attribute_field     = string
    }))
    jwt_token_type_configuration = optional(object({
      key_location               = string
      url                       = optional(string)
      secret_manager_arn        = optional(string)
      user_name_attribute_field = string
      group_attribute_field     = optional(string)
      issuer                    = optional(string)
      claim_regex               = optional(string)
    }))
  }))
  default = []
}

# Document Metadata Configuration
variable "document_metadata_configurations" {
  description = "Document metadata configurations"
  type = list(object({
    name = string
    type = string
    relevance = optional(object({
      importance            = optional(number)
      freshness            = optional(bool)
      rank_order           = optional(string)
      duration             = optional(string)
      values_importance_map = optional(map(number))
    }))
    search = optional(object({
      facetable   = optional(bool)
      searchable  = optional(bool)
      displayable = optional(bool)
      sortable    = optional(bool)
    }))
  }))
  default = []
}

# S3 Data Source Configuration
variable "create_s3_data_source" {
  description = "Create S3 data source for the index"
  type        = bool
  default     = false
}

variable "s3_data_source_description" {
  description = "Description of the S3 data source"
  type        = string
  default     = "S3 data source for Kendra index"
}

variable "s3_data_source_bucket_name" {
  description = "S3 bucket name for the data source"
  type        = string
  default     = null
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs for data source access"
  type        = list(string)
  default     = []
}

variable "s3_data_source_schedule" {
  description = "Schedule for S3 data source synchronization"
  type        = string
  default     = null
}

variable "s3_inclusion_prefixes" {
  description = "S3 inclusion prefixes for data source"
  type        = list(string)
  default     = null
}

variable "s3_exclusion_patterns" {
  description = "S3 exclusion patterns for data source"
  type        = list(string)
  default     = null
}

variable "s3_documents_metadata_configuration" {
  description = "S3 documents metadata configuration"
  type = object({
    s3_prefix = string
  })
  default = null
}

variable "s3_access_control_list_configuration" {
  description = "S3 access control list configuration"
  type = object({
    key_path = string
  })
  default = null
}

variable "language_code" {
  description = "Language code for the index"
  type        = string
  default     = "en"
  validation {
    condition = contains([
      "ar", "hy", "eu", "bg", "ca", "zh", "zh-TW", "hr", "cs", "da", "nl", "en", "et", "fi", "fr", "gl", "de", "el", "hi", "hu", "is", "id", "ga", "it", "ja", "ko", "lv", "lt", "ms", "no", "fa", "pl", "pt", "pt-BR", "ro", "ru", "sr", "sk", "sl", "es", "sv", "th", "tr", "uk", "vi"
    ], var.language_code)
    error_message = "Language code must be a valid ISO 639-1 language code supported by Kendra."
  }
}

# Custom Data Sources
variable "custom_data_sources" {
  description = "Map of custom data sources to create"
  type = map(object({
    name          = string
    type          = string
    role_arn      = string
    description   = optional(string)
    language_code = optional(string)
    schedule      = optional(string)
    configuration = optional(any)
    tags          = optional(map(string), {})
  }))
  default = {}
}

# FAQ Configuration
variable "faqs" {
  description = "Map of FAQ configurations"
  type = map(object({
    name          = string
    role_arn      = string
    description   = optional(string)
    file_format   = optional(string, "CSV")
    language_code = optional(string)
    s3_bucket     = string
    s3_key        = string
    tags          = optional(map(string), {})
  }))
  default = {}
}

# Thesaurus Configuration
variable "thesaurus_configurations" {
  description = "Map of thesaurus configurations"
  type = map(object({
    name        = string
    role_arn    = string
    description = optional(string)
    s3_bucket   = string
    s3_key      = string
    tags        = optional(map(string), {})
  }))
  default = {}
}

# Query Suggestions Block List
variable "query_suggestions_block_lists" {
  description = "Map of query suggestions block list configurations"
  type = map(object({
    name        = string
    role_arn    = string
    description = optional(string)
    s3_bucket   = string
    s3_key      = string
    tags        = optional(map(string), {})
  }))
  default = {}
}

# Search Experience Configuration
variable "create_search_experience" {
  description = "Create Kendra search experience"
  type        = bool
  default     = false
}

variable "search_experience_description" {
  description = "Description of the search experience"
  type        = string
  default     = "Kendra search experience for document search"
}

variable "search_experience_role_arn" {
  description = "IAM role ARN for search experience (if not provided, one will be created)"
  type        = string
  default     = null
}

variable "search_experience_configuration" {
  description = "Configuration for search experience"
  type = object({
    content_source_configuration = optional(object({
      data_source_ids    = optional(list(string))
      faq_ids           = optional(list(string))
      direct_put_content = optional(bool)
    }))
    user_identity_configuration = optional(object({
      identity_attribute_name = string
    }))
  })
  default = null
}

# Lambda Integration
variable "create_lambda_integration_role" {
  description = "Create IAM role for Lambda integration with Kendra"
  type        = bool
  default     = false
}

# Logging Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "log_kms_key_id" {
  description = "KMS key ID for CloudWatch log encryption"
  type        = string
  default     = null
}

# Ranking Configuration
variable "enable_ranking" {
  description = "Enable Kendra ranking capabilities"
  type        = bool
  default     = false
}

variable "ranking_plan_name" {
  description = "Name for the Kendra ranking plan"
  type        = string
  default     = "MyKendraRankingPlan"
}

# Query Suggestions Configuration
variable "enable_query_suggestions" {
  description = "Enable query suggestions for the index"
  type        = bool
  default     = true
}

variable "query_suggestions_mode" {
  description = "Mode for query suggestions"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "LEARN_ONLY"], var.query_suggestions_mode)
    error_message = "Query suggestions mode must be either ENABLED or LEARN_ONLY."
  }
}

# Faceting Configuration
variable "enable_faceting" {
  description = "Enable faceting for search results"
  type        = bool
  default     = true
}

variable "facet_configurations" {
  description = "Facet configurations for search"
  type = list(object({
    facet_name = string
    facet_type = string
    max_results = optional(number, 10)
  }))
  default = []
}

# Integration Configuration
variable "bedrock_integration" {
  description = "Enable integration with Amazon Bedrock for enhanced search"
  type        = bool
  default     = false
}

variable "opensearch_integration" {
  description = "Enable integration with OpenSearch for hybrid search"
  type        = bool
  default     = false
}

variable "opensearch_domain_arn" {
  description = "OpenSearch domain ARN for integration"
  type        = string
  default     = null
}

# Performance Configuration
variable "enable_performance_monitoring" {
  description = "Enable performance monitoring and metrics"
  type        = bool
  default     = true
}

variable "query_timeout_seconds" {
  description = "Query timeout in seconds"
  type        = number
  default     = 30
  validation {
    condition     = var.query_timeout_seconds >= 1 && var.query_timeout_seconds <= 300
    error_message = "Query timeout must be between 1 and 300 seconds."
  }
}

# Cost Optimization
variable "enable_cost_optimization" {
  description = "Enable cost optimization features"
  type        = bool
  default     = true
}

variable "auto_scaling_enabled" {
  description = "Enable auto-scaling for capacity units"
  type        = bool
  default     = false
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all Kendra resources"
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
  description = "Additional tags to apply to all Kendra resources"
  type        = map(string)
  default     = {}
}
