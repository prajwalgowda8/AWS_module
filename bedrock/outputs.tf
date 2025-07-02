
output "bedrock_execution_role_arn" {
  description = "ARN of the Bedrock execution IAM role"
  value       = aws_iam_role.bedrock_execution_role.arn
}

output "bedrock_execution_role_name" {
  description = "Name of the Bedrock execution IAM role"
  value       = aws_iam_role.bedrock_execution_role.name
}

output "knowledge_base_role_arn" {
  description = "ARN of the Knowledge Base IAM role (if created)"
  value       = var.create_knowledge_base ? aws_iam_role.knowledge_base_role[0].arn : null
}

output "knowledge_base_role_name" {
  description = "Name of the Knowledge Base IAM role (if created)"
  value       = var.create_knowledge_base ? aws_iam_role.knowledge_base_role[0].name : null
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution IAM role (if created)"
  value       = var.create_lambda_execution_role ? aws_iam_role.bedrock_lambda_role[0].arn : null
}

output "lambda_execution_role_name" {
  description = "Name of the Lambda execution IAM role (if created)"
  value       = var.create_lambda_execution_role ? aws_iam_role.bedrock_lambda_role[0].name : null
}

output "log_group_name" {
  description = "CloudWatch log group name for Bedrock"
  value       = aws_cloudwatch_log_group.bedrock_logs.name
}

output "log_group_arn" {
  description = "CloudWatch log group ARN for Bedrock"
  value       = aws_cloudwatch_log_group.bedrock_logs.arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name (if created)"
  value       = var.create_cloudwatch_dashboard ? aws_cloudwatch_dashboard.bedrock_dashboard[0].dashboard_name : null
}

output "provisioned_model_arn" {
  description = "ARN of the provisioned model throughput (if created)"
  value       = var.create_provisioned_throughput ? aws_bedrock_provisioned_model_throughput.this[0].id : null
}

# Model Configuration Outputs
output "enabled_models" {
  description = "List of enabled Bedrock foundation models"
  value       = var.enabled_models
}

output "embedding_model_id" {
  description = "Model ID used for text embeddings"
  value       = var.embedding_model_id
}

# Model ARNs for application integration
output "model_arns" {
  description = "Map of model names to their ARNs"
  value = {
    for model in var.enabled_models :
    model => "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${model}"
  }
}

# Claude Models Configuration
output "claude_3_haiku_arn" {
  description = "ARN for Claude 3 Haiku model"
  value       = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
}

output "claude_3_5_sonnet_arn" {
  description = "ARN for Claude 3.5 Sonnet model"
  value       = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0"
}

output "claude_3_5_haiku_arn" {
  description = "ARN for Claude 3.5 Haiku model"
  value       = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/anthropic.claude-3-5-haiku-20241022-v1:0"
}

# Titan Models Configuration
output "titan_text_embeddings_v2_arn" {
  description = "ARN for Titan Text Embeddings V2 model"
  value       = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
}

output "titan_text_express_arn" {
  description = "ARN for Titan Text Express model"
  value       = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-text-express-v1"
}

# Knowledge Base Configuration
output "knowledge_base_config" {
  description = "Knowledge base configuration for RAG applications"
  value = var.create_knowledge_base ? {
    name                    = var.knowledge_base_name
    description            = var.knowledge_base_description
    embedding_model_arn    = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model_id}"
    s3_bucket_arn          = var.knowledge_base_s3_bucket_arn
    s3_key_prefix          = var.knowledge_base_s3_key_prefix
    vector_store_type      = var.vector_store_type
    opensearch_collection_arn = var.opensearch_collection_arn
    chunking_strategy      = var.chunking_strategy
    max_tokens_per_chunk   = var.max_tokens_per_chunk
    overlap_percentage     = var.overlap_percentage
  } : null
}

# Application Integration Outputs
output "bedrock_config" {
  description = "Complete Bedrock configuration for application integration"
  value = {
    service_name           = var.service_name
    region                = data.aws_region.current.name
    account_id            = data.aws_caller_identity.current.account_id
    execution_role_arn    = aws_iam_role.bedrock_execution_role.arn
    lambda_role_arn       = var.create_lambda_execution_role ? aws_iam_role.bedrock_lambda_role[0].arn : null
    log_group_name        = aws_cloudwatch_log_group.bedrock_logs.name
    enabled_models        = var.enabled_models
    embedding_model_id    = var.embedding_model_id
    logging_enabled       = var.enable_model_invocation_logging
    monitoring_enabled    = var.create_cloudwatch_dashboard
    knowledge_base_enabled = var.create_knowledge_base
  }
}

# Security Configuration
output "security_config" {
  description = "Security configuration for Bedrock"
  value = {
    execution_role_arn     = aws_iam_role.bedrock_execution_role.arn
    knowledge_base_role_arn = var.create_knowledge_base ? aws_iam_role.knowledge_base_role[0].arn : null
    lambda_role_arn        = var.create_lambda_execution_role ? aws_iam_role.bedrock_lambda_role[0].arn : null
    allowed_principals     = var.allowed_principals
    allowed_source_ips     = var.allowed_source_ips
    logging_enabled        = var.enable_model_invocation_logging
  }
}

# Monitoring Configuration
output "monitoring_config" {
  description = "Monitoring configuration for Bedrock"
  value = {
    log_group_name         = aws_cloudwatch_log_group.bedrock_logs.name
    log_group_arn          = aws_cloudwatch_log_group.bedrock_logs.arn
    dashboard_enabled      = var.create_cloudwatch_dashboard
    dashboard_name         = var.create_cloudwatch_dashboard ? aws_cloudwatch_dashboard.bedrock_dashboard[0].dashboard_name : null
    alarms_enabled         = var.create_cloudwatch_alarms
    error_rate_threshold   = var.error_rate_threshold
    latency_threshold      = var.latency_threshold
    log_retention_days     = var.log_retention_days
  }
}

# Model-specific Configuration Outputs
output "claude_models_config" {
  description = "Configuration for Claude models"
  value = {
    max_tokens_to_sample = var.claude_models_config.max_tokens_to_sample
    temperature         = var.claude_models_config.temperature
    top_p              = var.claude_models_config.top_p
    top_k              = var.claude_models_config.top_k
    stop_sequences     = var.claude_models_config.stop_sequences
  }
}

output "titan_models_config" {
  description = "Configuration for Titan models"
  value = {
    max_token_count    = var.titan_models_config.max_token_count
    temperature        = var.titan_models_config.temperature
    top_p             = var.titan_models_config.top_p
    stop_sequences    = var.titan_models_config.stop_sequences
  }
}

# Provisioned Throughput Configuration
output "provisioned_throughput_config" {
  description = "Provisioned throughput configuration (if enabled)"
  value = var.create_provisioned_throughput ? {
    model_id               = var.provisioned_model_id
    model_units           = var.provisioned_model_units
    commitment_duration   = var.provisioned_commitment_duration
    provisioned_model_arn = aws_bedrock_provisioned_model_throughput.this[0].id
  } : null
}

# RAG Application Integration
output "rag_integration" {
  description = "Configuration for RAG (Retrieval-Augmented Generation) applications"
  value = {
    knowledge_base_enabled = var.create_knowledge_base
    embedding_model_arn   = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model_id}"
    text_generation_models = [
      for model in var.enabled_models : 
      "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${model}"
      if can(regex("^(anthropic\\.|amazon\\.titan-text)", model))
    ]
    vector_store_config = var.create_knowledge_base ? {
      type                   = var.vector_store_type
      opensearch_collection_arn = var.opensearch_collection_arn
      index_name            = var.opensearch_vector_index_name
      vector_field          = var.opensearch_vector_field_name
      text_field           = var.opensearch_text_field
      metadata_field       = var.opensearch_metadata_field
    } : null
  }
}

# Cost Optimization Outputs
output "cost_optimization" {
  description = "Cost optimization recommendations and configuration"
  value = {
    provisioned_throughput_enabled = var.create_provisioned_throughput
    on_demand_models              = [
      for model in var.enabled_models : model
      if !var.create_provisioned_throughput || model != var.provisioned_model_id
    ]
    log_retention_days            = var.log_retention_days
    monitoring_enabled            = var.create_cloudwatch_dashboard
    recommendations = {
      use_provisioned_throughput = "Consider provisioned throughput for high-volume, predictable workloads"
      optimize_chunking         = "Adjust chunking strategy based on your document types and query patterns"
      monitor_usage            = "Use CloudWatch metrics to optimize model selection and usage patterns"
    }
  }
}
