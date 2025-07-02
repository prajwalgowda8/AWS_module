
# Common Variables
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

# Service Configuration
variable "service_name" {
  description = "Name of the Bedrock service"
  type        = string
  default     = "bedrock-service"
}

# Logging Configuration
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

# Knowledge Base Configuration
variable "create_knowledge_base" {
  description = "Whether to create a knowledge base"
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
  default     = null
}

variable "knowledge_base_s3_bucket_arn" {
  description = "ARN of the S3 bucket for knowledge base"
  type        = string
  default     = null
}

variable "knowledge_base_s3_key_prefix" {
  description = "S3 key prefix for knowledge base"
  type        = string
  default     = null
}

# Model Configuration
variable "enabled_models" {
  description = "List of enabled Bedrock foundation models"
  type        = list(string)
  default     = []
}

variable "embedding_model_id" {
  description = "Model ID used for text embeddings"
  type        = string
  default     = null
}

# Vector Store Configuration
variable "vector_store_type" {
  description = "Type of vector store to use"
  type        = string
  default     = "opensearch"
}

variable "opensearch_collection_arn" {
  description = "ARN of the OpenSearch collection"
  type        = string
  default     = null
}

variable "opensearch_vector_index_name" {
  description = "Name of the OpenSearch vector index"
  type        = string
  default     = "embeddings"
}

variable "opensearch_vector_field_name" {
  description = "Name of the vector field in OpenSearch"
  type        = string
  default     = "vector"
}

variable "opensearch_text_field" {
  description = "Name of the text field in OpenSearch"
  type        = string
  default     = "text"
}

variable "opensearch_metadata_field" {
  description = "Name of the metadata field in OpenSearch"
  type        = string
  default     = "metadata"
}

# Chunking Configuration
variable "chunking_strategy" {
  description = "Strategy for chunking text"
  type        = string
  default     = "fixed_size"
}

variable "max_tokens_per_chunk" {
  description = "Maximum number of tokens per chunk"
  type        = number
  default     = 1000
}

variable "overlap_percentage" {
  description = "Percentage of overlap between chunks"
  type        = number
  default     = 20
}

# Lambda Integration
variable "create_lambda_execution_role" {
  description = "Whether to create a Lambda execution role"
  type        = bool
  default     = false
}

# Security Configuration
variable "allowed_principals" {
  description = "List of AWS principals allowed to access Bedrock"
  type        = list(string)
  default     = []
}

variable "allowed_source_ips" {
  description = "List of source IPs allowed to access Bedrock"
  type        = list(string)
  default     = []
}

# Monitoring Configuration
variable "enable_model_invocation_logging" {
  description = "Enable logging of model invocations"
  type        = bool
  default     = true
}

variable "create_cloudwatch_dashboard" {
  description = "Create CloudWatch dashboard for monitoring"
  type        = bool
  default     = false
}

variable "create_cloudwatch_alarms" {
  description = "Create CloudWatch alarms for monitoring"
  type        = bool
  default     = false
}

variable "error_rate_threshold" {
  description = "Error rate threshold for alarms"
  type        = number
  default     = 1
}

variable "latency_threshold" {
  description = "Latency threshold for alarms (in milliseconds)"
  type        = number
  default     = 1000
}

# Provisioned Throughput Configuration
variable "create_provisioned_throughput" {
  description = "Create provisioned throughput for models"
  type        = bool
  default     = false
}

variable "provisioned_model_id" {
  description = "ID of the model for provisioned throughput"
  type        = string
  default     = null
}

variable "provisioned_model_units" {
  description = "Number of provisioned throughput units"
  type        = number
  default     = 1
}

variable "provisioned_commitment_duration" {
  description = "Duration of provisioned throughput commitment"
  type        = string
  default     = "1month"
}
