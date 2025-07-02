
# AWS Bedrock Configuration
module "bedrock" {
  source = "${local.module_source}bedrock"

  # Service Configuration
  service_name = var.bedrock_service_name

  # Model Configuration
  enabled_models      = var.bedrock_enabled_models
  embedding_model_id  = var.bedrock_embedding_model_id

  # Logging Configuration
  log_retention_days              = var.bedrock_log_retention_days
  log_kms_key_id                 = null
  enable_model_invocation_logging = var.bedrock_enable_model_invocation_logging

  # Monitoring Configuration
  create_cloudwatch_dashboard = var.bedrock_create_cloudwatch_dashboard
  create_cloudwatch_alarms    = false
  error_rate_threshold        = 1
  latency_threshold          = 1000

  # Lambda Integration
  create_lambda_execution_role = var.bedrock_create_lambda_execution_role

  # Knowledge Base Configuration (disabled by default)
  create_knowledge_base        = var.bedrock_create_knowledge_base
  knowledge_base_name         = null
  knowledge_base_description  = null
  knowledge_base_s3_bucket_arn = null
  knowledge_base_s3_key_prefix = null

  # Vector Store Configuration
  vector_store_type              = "opensearch"
  opensearch_collection_arn      = null
  opensearch_vector_index_name   = "embeddings"
  opensearch_vector_field_name   = "vector"
  opensearch_text_field         = "text"
  opensearch_metadata_field     = "metadata"

  # Chunking Configuration
  chunking_strategy      = "fixed_size"
  max_tokens_per_chunk   = 1000
  overlap_percentage     = 20

  # Security Configuration
  allowed_principals  = []
  allowed_source_ips  = []

  # Provisioned Throughput (disabled by default)
  create_provisioned_throughput   = false
  provisioned_model_id           = null
  provisioned_model_units        = 1
  provisioned_commitment_duration = "1month"

  # Mandatory Organizational Tags
  contact_group                 = var.contact_group
  contact_name                  = var.contact_name
  cost_bucket                   = var.cost_bucket
  data_owner                    = var.data_owner
  display_name                  = var.display_name
  environment                   = var.environment
  has_public_ip                 = var.has_public_ip
  has_unisys_network_connection = var.has_unisys_network_connection
  service_line                  = var.service_line

  # Common tags
  common_tags = {
    Project     = var.project_name
    ManagedBy   = "terraform"
    Component   = "bedrock-service"
    Application = "Study Companion RAG"
  }
}

# Outputs for AWS Bedrock
output "bedrock_execution_role_arn" {
  description = "ARN of the Bedrock execution IAM role"
  value       = module.bedrock.bedrock_execution_role_arn
}

output "bedrock_execution_role_name" {
  description = "Name of the Bedrock execution IAM role"
  value       = module.bedrock.bedrock_execution_role_name
}

output "bedrock_log_group_name" {
  description = "CloudWatch log group name for Bedrock"
  value       = module.bedrock.log_group_name
}

output "bedrock_log_group_arn" {
  description = "CloudWatch log group ARN for Bedrock"
  value       = module.bedrock.log_group_arn
}

output "bedrock_enabled_models" {
  description = "List of enabled Bedrock foundation models"
  value       = module.bedrock.enabled_models
}

output "bedrock_embedding_model_id" {
  description = "Model ID used for text embeddings"
  value       = module.bedrock.embedding_model_id
}

output "bedrock_model_arns" {
  description = "Map of model names to their ARNs"
  value       = module.bedrock.model_arns
}

output "bedrock_claude_3_haiku_arn" {
  description = "ARN for Claude 3 Haiku model"
  value       = module.bedrock.claude_3_haiku_arn
}

output "bedrock_claude_3_5_sonnet_arn" {
  description = "ARN for Claude 3.5 Sonnet model"
  value       = module.bedrock.claude_3_5_sonnet_arn
}

output "bedrock_claude_3_5_haiku_arn" {
  description = "ARN for Claude 3.5 Haiku model"
  value       = module.bedrock.claude_3_5_haiku_arn
}

output "bedrock_titan_text_embeddings_v2_arn" {
  description = "ARN for Titan Text Embeddings V2 model"
  value       = module.bedrock.titan_text_embeddings_v2_arn
}

output "bedrock_config" {
  description = "Complete Bedrock configuration for application integration"
  value       = module.bedrock.bedrock_config
}

output "bedrock_rag_integration" {
  description = "Configuration for RAG (Retrieval-Augmented Generation) applications"
  value       = module.bedrock.rag_integration
}
