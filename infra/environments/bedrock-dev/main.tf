
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Local values for environment-specific configuration
locals {
  environment = "dev"
  project     = "sc-bedrock-textgen-demo"
  
  # Common tags for all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedDate = "2025-01-02"
  }
}

# Random ID for bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket for Knowledge Base documents
resource "aws_s3_bucket" "knowledge_base_documents" {
  bucket        = "${local.project}-knowledge-base-${local.environment}-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = merge(
    local.common_tags,
    {
      Name    = "${local.project}-knowledge-base-documents"
      Purpose = "Knowledge Base document storage for RAG"
    }
  )
}

resource "aws_s3_bucket_versioning" "knowledge_base_documents" {
  bucket = aws_s3_bucket.knowledge_base_documents.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "knowledge_base_documents" {
  bucket = aws_s3_bucket.knowledge_base_documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create sample folders in S3 bucket
resource "aws_s3_object" "documents_folder" {
  bucket = aws_s3_bucket.knowledge_base_documents.id
  key    = "documents/"
  content = ""
  tags = local.common_tags
}

resource "aws_s3_object" "study_materials_folder" {
  bucket = aws_s3_bucket.knowledge_base_documents.id
  key    = "documents/study-materials/"
  content = ""
  tags = local.common_tags
}

resource "aws_s3_object" "textbooks_folder" {
  bucket = aws_s3_bucket.knowledge_base_documents.id
  key    = "documents/textbooks/"
  content = ""
  tags = local.common_tags
}

# OpenSearch Serverless collection for vector storage
resource "aws_opensearchserverless_collection" "bedrock_knowledge_base" {
  name = "${local.project}-vector-store"
  type = "VECTORSEARCH"
  description = "Vector store for Bedrock Knowledge Base"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project}-vector-store"
    }
  )
}

# OpenSearch Serverless security policy
resource "aws_opensearchserverless_security_policy" "bedrock_encryption" {
  name = "${local.project}-encryption-policy"
  type = "encryption"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${local.project}-vector-store"
        ]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "bedrock_network" {
  name = "${local.project}-network-policy"
  type = "network"
  policy = jsonencode([
    {
      Rules = [
        {
          Resource = [
            "collection/${local.project}-vector-store"
          ]
          ResourceType = "collection"
        }
      ]
      AllowFromPublic = true
    }
  ])
}

# SNS topic for Bedrock alarms
resource "aws_sns_topic" "bedrock_alarms" {
  name = "${local.project}-bedrock-alarms"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project}-bedrock-alarms"
    }
  )
}

# AWS Bedrock Module
module "bedrock" {
  source = "../../bedrock"
  
  # Service configuration
  service_name        = "sc-bedrock-textgen-demo"
  service_description = "RAG-based Generative AI application for Study Companion"
  
  # Model configuration - Titan Text Embeddings V2, Claude 3 Haiku, Claude 3.5 Sonnet, Claude 3.5 Haiku
  enabled_models = [
    "amazon.titan-embed-text-v2:0",
    "anthropic.claude-3-haiku-20240307-v1:0",
    "anthropic.claude-3-5-sonnet-20241022-v2:0",
    "anthropic.claude-3-5-haiku-20241022-v1:0"
  ]
  
  embedding_model_id = "amazon.titan-embed-text-v2:0"
  
  # Knowledge Base configuration for RAG
  create_knowledge_base       = true
  knowledge_base_name         = "sc-bedrock-textgen-demo-kb"
  knowledge_base_description  = "Knowledge base for Study Companion RAG-based Generative AI application"
  knowledge_base_s3_bucket_arn = aws_s3_bucket.knowledge_base_documents.arn
  knowledge_base_s3_key_prefix = "documents/"
  
  # Vector store configuration
  vector_store_type         = "opensearch"
  opensearch_collection_arn = aws_opensearchserverless_collection.bedrock_knowledge_base.arn
  
  # Chunking strategy for study materials
  chunking_strategy     = "FIXED_SIZE"
  max_tokens_per_chunk  = 500
  overlap_percentage    = 20
  
  # Logging configuration
  enable_model_invocation_logging = true
  log_retention_days             = 30
  log_embedding_data             = true
  log_text_data                  = true
  log_image_data                 = false
  
  # IAM roles
  create_lambda_execution_role = true
  create_application_role      = true
  
  # Monitoring configuration
  create_cloudwatch_dashboard = true
  create_cloudwatch_alarms    = true
  error_rate_threshold        = 5
  latency_threshold          = 10000
  alarm_actions              = [aws_sns_topic.bedrock_alarms.arn]
  
  # Model-specific configuration for Study Companion
  claude_models_config = {
    max_tokens_to_sample = 4000
    temperature         = 0.7
    top_p              = 0.9
    top_k              = 250
    stop_sequences     = ["Human:", "Assistant:"]
  }
  
  titan_models_config = {
    max_token_count = 4000
    temperature     = 0.7
    top_p          = 0.9
    stop_sequences = []
  }
  
  # Security configuration
  enable_guardrails = true
  guardrails_config = {
    blocked_input_messaging  = "This content violates our educational content policies."
    blocked_output_messaging = "I can't provide that type of educational content."
  }
  
  # Provisioned throughput (disabled for dev environment)
  create_provisioned_throughput = false
  
  # Mandatory tags
  common_tags                    = local.common_tags
  contact_group                  = "AI/ML Team"
  contact_name                   = "Emily Rodriguez"
  cost_bucket                    = "development"
  data_owner                     = "AI Research Team"
  display_name                   = "SC Bedrock Text Generation Demo Development"
  environment                    = local.environment
  has_public_ip                  = "false"
  has_unisys_network_connection  = "false"
  service_line                   = "AI/ML Services"
}

# Output Bedrock information
output "bedrock_execution_role_arn" {
  description = "ARN of the Bedrock execution IAM role"
  value       = module.bedrock.bedrock_execution_role_arn
}

output "knowledge_base_role_arn" {
  description = "ARN of the Knowledge Base IAM role"
  value       = module.bedrock.knowledge_base_role_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution IAM role"
  value       = module.bedrock.lambda_execution_role_arn
}

output "application_role_arn" {
  description = "ARN of the application IAM role"
  value       = module.bedrock.bedrock_application_role_arn
}

output "log_group_name" {
  description = "CloudWatch log group name for Bedrock"
  value       = module.bedrock.log_group_name
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.bedrock.dashboard_name
}

output "enabled_models" {
  description = "List of enabled Bedrock foundation models"
  value       = module.bedrock.enabled_models
}

output "model_arns" {
  description = "Map of model names to their ARNs"
  value       = module.bedrock.model_arns
}

output "knowledge_base_s3_bucket" {
  description = "S3 bucket for Knowledge Base documents"
  value = {
    bucket_name = aws_s3_bucket.knowledge_base_documents.id
    bucket_arn  = aws_s3_bucket.knowledge_base_documents.arn
  }
}

output "opensearch_collection" {
  description = "OpenSearch Serverless collection for vector storage"
  value = {
    collection_name = aws_opensearchserverless_collection.bedrock_knowledge_base.name
    collection_arn  = aws_opensearchserverless_collection.bedrock_knowledge_base.arn
    endpoint        = aws_opensearchserverless_collection.bedrock_knowledge_base.collection_endpoint
  }
}

output "bedrock_config" {
  description = "Complete Bedrock configuration for application integration"
  value       = module.bedrock.bedrock_config
}

output "rag_integration" {
  description = "Configuration for RAG applications"
  value       = module.bedrock.rag_integration
}

output "security_config" {
  description = "Security configuration for Bedrock"
  value       = module.bedrock.security_config
}

output "monitoring_config" {
  description = "Monitoring configuration for Bedrock"
  value       = module.bedrock.monitoring_config
}

output "claude_models_config" {
  description = "Configuration for Claude models"
  value       = module.bedrock.claude_models_config
}

output "titan_models_config" {
  description = "Configuration for Titan models"
  value       = module.bedrock.titan_models_config
}

output "sns_alarm_topic_arn" {
  description = "ARN of the SNS topic for Bedrock alarms"
  value       = aws_sns_topic.bedrock_alarms.arn
}
