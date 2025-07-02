
variable "service_name" {
  description = "Name of the service using Bedrock"
  type        = string
}

# Model Configuration
variable "enabled_models" {
  description = "List of Bedrock foundation models to enable access for"
  type        = list(string)
  default = [
    "amazon.titan-text-express-v1",
    "amazon.titan-embed-text-v2:0",
    "anthropic.claude-3-haiku-20240307-v1:0",
    "anthropic.claude-3-5-sonnet-20241022-v2:0",
    "anthropic.claude-3-5-haiku-20241022-v1:0"
  ]
  validation {
    condition = alltrue([
      for model in var.enabled_models : 
      can(regex("^(amazon\\.|anthropic\\.|ai21\\.|cohere\\.|meta\\.|mistral\\.|stability\\.)", model))
    ])
    error_message = "All models must be valid Bedrock foundation model identifiers."
  }
}

variable "embedding_model_id" {
  description = "Model ID for text embeddings (used in knowledge base)"
  type        = string
  default     = "amazon.titan-embed-text-v2:0"
}

# Knowledge Base Configuration
variable "create_knowledge_base" {
  description = "Create a Bedrock Knowledge Base for RAG applications"
  type        = bool
  default     = false
}

variable "knowledge_base_name" {
  description = "Name of the knowledge base"
  type        = string
  default     = null
}

variable "knowledge_base_description" {
  description = "Description of the knowledge base"
  type        = string
  default     = "Knowledge base for RAG applications"
}

variable "knowledge_base_s3_bucket_arn" {
  description = "ARN of S3 bucket containing knowledge base documents"
  type        = string
  default     = null
}

variable "knowledge_base_s3_key_prefix" {
  description = "S3 key prefix for knowledge base documents"
  type        = string
  default     = "documents/"
}

variable "vector_store_type" {
  description = "Type of vector store for knowledge base"
  type        = string
  default     = "opensearch"
  validation {
    condition     = contains(["opensearch", "pinecone", "redis"], var.vector_store_type)
    error_message = "Vector store type must be one of: opensearch, pinecone, redis."
  }
}

variable "opensearch_collection_arn" {
  description = "ARN of OpenSearch Serverless collection for vector storage"
  type        = string
  default     = null
}

variable "opensearch_vector_index_name" {
  description = "Name of the vector index in OpenSearch"
  type        = string
  default     = "bedrock-knowledge-base-index"
}

variable "opensearch_vector_field_name" {
  description = "Name of the vector field in OpenSearch"
  type        = string
  default     = "bedrock-knowledge-base-default-vector"
}

variable "opensearch_text_field" {
  description = "Name of the text field in OpenSearch"
  type        = string
  default     = "AMAZON_BEDROCK_TEXT_CHUNK"
}

variable "opensearch_metadata_field" {
  description = "Name of the metadata field in OpenSearch"
  type        = string
  default     = "AMAZON_BEDROCK_METADATA"
}

# Chunking Strategy Configuration
variable "chunking_strategy" {
  description = "Chunking strategy for knowledge base documents"
  type        = string
  default     = "FIXED_SIZE"
  validation {
    condition     = contains(["FIXED_SIZE", "NONE"], var.chunking_strategy)
    error_message = "Chunking strategy must be either FIXED_SIZE or NONE."
  }
}

variable "max_tokens_per_chunk" {
  description = "Maximum tokens per chunk"
  type        = number
  default     = 300
  validation {
    condition     = var.max_tokens_per_chunk >= 1 && var.max_tokens_per_chunk <= 8192
    error_message = "Max tokens per chunk must be between 1 and 8192."
  }
}

variable "overlap_percentage" {
  description = "Overlap percentage between chunks"
  type        = number
  default     = 20
  validation {
    condition     = var.overlap_percentage >= 1 && var.overlap_percentage <= 99
    error_message = "Overlap percentage must be between 1 and 99."
  }
}

# Logging Configuration
variable "enable_model_invocation_logging" {
  description = "Enable model invocation logging"
  type        = bool
  default     = true
}

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

variable "log_embedding_data" {
  description = "Enable logging of embedding data"
  type        = bool
  default     = false
}

variable "log_image_data" {
  description = "Enable logging of image data"
  type        = bool
  default     = false
}

variable "log_text_data" {
  description = "Enable logging of text data"
  type        = bool
  default     = true
}

# IAM Role Configuration
variable "create_lambda_execution_role" {
  description = "Create IAM role for Lambda functions to access Bedrock"
  type        = bool
  default     = false
}

# Monitoring Configuration
variable "create_cloudwatch_dashboard" {
  description = "Create CloudWatch dashboard for Bedrock monitoring"
  type        = bool
  default     = true
}

variable "create_cloudwatch_alarms" {
  description = "Create CloudWatch alarms for Bedrock monitoring"
  type        = bool
  default     = true
}

variable "error_rate_threshold" {
  description = "Threshold for error rate alarm"
  type        = number
  default     = 10
}

variable "latency_threshold" {
  description = "Threshold for latency alarm (in milliseconds)"
  type        = number
  default     = 5000
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

# Provisioned Throughput Configuration
variable "create_provisioned_throughput" {
  description = "Create provisioned model throughput for high-volume applications"
  type        = bool
  default     = false
}

variable "provisioned_model_id" {
  description = "Model ID for provisioned throughput"
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "provisioned_model_units" {
  description = "Number of model units for provisioned throughput"
  type        = number
  default     = 1
  validation {
    condition     = var.provisioned_model_units >= 1
    error_message = "Provisioned model units must be at least 1."
  }
}

variable "provisioned_commitment_duration" {
  description = "Commitment duration for provisioned throughput"
  type        = string
  default     = "OneMonth"
  validation {
    condition     = contains(["OneMonth", "SixMonths"], var.provisioned_commitment_duration)
    error_message = "Commitment duration must be either OneMonth or SixMonths."
  }
}

# Model-specific Configuration
variable "claude_models_config" {
  description = "Configuration for Claude models"
  type = object({
    max_tokens_to_sample = optional(number, 1000)
    temperature         = optional(number, 0.7)
    top_p              = optional(number, 0.9)
    top_k              = optional(number, 250)
    stop_sequences     = optional(list(string), [])
  })
  default = {}
}

variable "titan_models_config" {
  description = "Configuration for Titan models"
  type = object({
    max_token_count    = optional(number, 1000)
    temperature        = optional(number, 0.7)
    top_p             = optional(number, 0.9)
    stop_sequences    = optional(list(string), [])
  })
  default = {}
}

# Security Configuration
variable "allowed_principals" {
  description = "List of IAM principals allowed to invoke Bedrock models"
  type        = list(string)
  default     = []
}

variable "allowed_source_ips" {
  description = "List of IP addresses/CIDR blocks allowed to access Bedrock"
  type        = list(string)
  default     = []
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all Bedrock resources"
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
  description = "Additional tags to apply to all Bedrock resources"
  type        = map(string)
  default     = {}
}
