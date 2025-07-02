
# =============================================================================
# AI/ML Services Configuration
# File 4 of 5: Bedrock, Transcribe, and Kendra resources
# =============================================================================

# Data sources to reference previous resources
data "aws_ssm_parameter" "project_config_aiml" {
  name = "/${var.project_name}/config/base"
}

data "aws_ssm_parameter" "compute_config_aiml" {
  name = "/${var.project_name}/config/compute"
}

data "aws_ssm_parameter" "data_config" {
  name = "/${var.project_name}/config/data"
}

locals {
  project_config_aiml = jsondecode(data.aws_ssm_parameter.project_config_aiml.value)
  compute_config_aiml = jsondecode(data.aws_ssm_parameter.compute_config_aiml.value)
  data_config = jsondecode(data.aws_ssm_parameter.data_config.value)
}

# =============================================================================
# Resource 1: AWS Bedrock (sc-bedrock-textgen-demo)
# =============================================================================

module "bedrock" {
  source = "./bedrock"

  service_name = "${local.project_config_aiml.service_prefix}-bedrock-textgen-${var.environment}"
  
  # Configure specified Bedrock models
  enabled_models = [
    "amazon.titan-embed-text-v2:0",
    "anthropic.claude-3-haiku-20240307-v1:0",
    "anthropic.claude-3-5-sonnet-20241022-v2:0",
    "anthropic.claude-3-5-haiku-20241022-v1:0"
  ]
  
  embedding_model_id = "amazon.titan-embed-text-v2:0"
  
  # Knowledge Base Configuration with OpenSearch integration
  create_knowledge_base = true
  knowledge_base_name = "${local.project_config_aiml.service_prefix}-knowledge-base-${var.environment}"
  knowledge_base_description = "Knowledge base for Study Companion RAG applications"
  knowledge_base_s3_bucket_arn = local.data_config.s3_bucket_arn
  knowledge_base_s3_key_prefix = "documents/"
  
  vector_store_type = "opensearch"
  opensearch_collection_arn = local.data_config.opensearch_domain_arn
  opensearch_vector_index_name = "bedrock-knowledge-base-index"
  opensearch_vector_field_name = "bedrock-knowledge-base-default-vector"
  opensearch_text_field = "AMAZON_BEDROCK_TEXT_CHUNK"
  opensearch_metadata_field = "AMAZON_BEDROCK_METADATA"
  
  # Chunking Strategy
  chunking_strategy = "FIXED_SIZE"
  max_tokens_per_chunk = 300
  overlap_percentage = 20
  
  # Lambda Integration
  create_lambda_execution_role = true
  
  # Logging and Monitoring
  enable_model_invocation_logging = true
  create_cloudwatch_dashboard = true
  create_cloudwatch_alarms = var.enable_detailed_monitoring
  
  log_retention_days = var.log_retention_days
  log_embedding_data = false
  log_image_data = false
  log_text_data = true
  
  # Alarm Configuration
  error_rate_threshold = 10
  latency_threshold = 5000
  alarm_actions = []
  
  # Model-specific Configuration
  claude_models_config = {
    max_tokens_to_sample = 1000
    temperature = 0.7
    top_p = 0.9
    top_k = 250
    stop_sequences = []
  }
  
  titan_models_config = {
    max_token_count = 1000
    temperature = 0.7
    top_p = 0.9
    stop_sequences = []
  }
  
  # Cost Optimization
  create_provisioned_throughput = false
  enable_cost_optimization = var.enable_cost_optimization

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "AI/ML"
    Service   = "Bedrock"
    Purpose   = "TextGeneration"
  }

  depends_on = [
    data.aws_ssm_parameter.project_config_aiml,
    data.aws_ssm_parameter.data_config
  ]
}

# =============================================================================
# Resource 2: Amazon Transcribe (sc-transcribe-demo)
# =============================================================================

module "transcribe" {
  source = "./transcribe"

  service_name = "${local.project_config_aiml.service_prefix}-transcribe-${var.environment}"
  s3_bucket_name = local.data_config.s3_bucket_id
  s3_bucket_arn = local.data_config.s3_bucket_arn
  
  # Language and Media Configuration
  language_code = "en-US"
  media_format = "mp3"
  media_sample_rate_hertz = null
  
  # Audio Processing Configuration
  channel_identification = false
  show_speaker_labels = true
  max_speaker_labels = 2
  
  # Custom Vocabulary (optional for better accuracy)
  create_custom_vocabulary = true
  vocabulary_phrases = [
    "Study Companion",
    "machine learning",
    "artificial intelligence",
    "data science",
    "natural language processing",
    "computer vision",
    "deep learning",
    "neural networks"
  ]
  
  # Language Model (disabled for demo)
  create_language_model = false
  
  # S3 Integration
  enable_s3_notifications = true
  lambda_function_arn = local.compute_config_aiml.lambda_function_arn
  s3_notification_events = ["s3:ObjectCreated:*"]
  s3_notification_filter_prefix = "audio/"
  s3_notification_filter_suffix = ".mp3"
  
  # Output Configuration
  output_bucket_name = local.data_config.s3_bucket_id
  output_key_prefix = "transcriptions/"
  
  # Lambda Integration
  create_lambda_trigger_role = true
  
  # Logging
  log_retention_days = var.log_retention_days

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "AI/ML"
    Service   = "Transcribe"
    Purpose   = "SpeechToText"
  }

  depends_on = [
    data.aws_ssm_parameter.data_config,
    data.aws_ssm_parameter.compute_config_aiml
  ]
}

# =============================================================================
# Resource 3: Amazon Kendra (with rescore execution plan)
# =============================================================================

module "kendra" {
  source = "./kendra"

  index_name = "${local.project_config_aiml.service_prefix}-kendra-${var.environment}"
  index_description = "Kendra search index for Study Companion documents with rescore execution plan"
  index_edition = "DEVELOPER_EDITION"
  
  # Capacity Configuration (for Enterprise Edition)
  capacity_units = null
  
  # Security Configuration
  kms_key_id = var.enable_encryption ? null : null
  user_context_policy = null
  user_group_resolution_mode = null
  
  # Document Metadata Configuration for better search
  document_metadata_configurations = [
    {
      name = "DocumentType"
      type = "STRING_VALUE"
      search = {
        facetable = true
        searchable = true
        displayable = true
        sortable = false
      }
      relevance = {
        importance = 5
        freshness = false
        rank_order = "ASCENDING"
      }
    },
    {
      name = "Subject"
      type = "STRING_VALUE"
      search = {
        facetable = true
        searchable = true
        displayable = true
        sortable = true
      }
      relevance = {
        importance = 8
        freshness = false
        rank_order = "ASCENDING"
      }
    },
    {
      name = "CreatedDate"
      type = "DATE_VALUE"
      search = {
        facetable = true
        searchable = false
        displayable = true
        sortable = true
      }
      relevance = {
        importance = 3
        freshness = true
        rank_order = "DESCENDING"
      }
    }
  ]
  
  # S3 Data Source Configuration
  create_s3_data_source = true
  s3_data_source_description = "S3 data source for Study Companion documents"
  s3_data_source_bucket_name = local.data_config.s3_bucket_id
  s3_bucket_arns = [local.data_config.s3_bucket_arn]
  s3_data_source_schedule = "cron(0 12 * * ? *)"  # Daily at 12 PM UTC
  s3_inclusion_prefixes = ["documents/", "processed/"]
  s3_exclusion_patterns = ["*.tmp", "*.log", "*/temp/*"]
  
  # Language Configuration
  language_code = "en"
  
  # Search Experience Configuration
  create_search_experience = true
  search_experience_description = "Search experience for Study Companion with rescore execution"
  search_experience_configuration = {
    content_source_configuration = {
      data_source_ids = null  # Will be populated after data source creation
      faq_ids = null
      direct_put_content = true
    }
    user_identity_configuration = null
  }
  
  # Lambda Integration for search and indexing
  create_lambda_integration_role = true
  
  # Query Suggestions and Faceting
  enable_query_suggestions = true
  query_suggestions_mode = "ENABLED"
  enable_faceting = true
  
  # Rescore Execution Plan Configuration
  enable_ranking = true
  ranking_plan_name = "StudyCompanionRescorePlan"
  
  # Performance and Cost Optimization
  enable_performance_monitoring = var.enable_detailed_monitoring
  query_timeout_seconds = 30
  enable_cost_optimization = var.enable_cost_optimization
  auto_scaling_enabled = false
  
  # Integration with other services
  bedrock_integration = true
  opensearch_integration = true
  opensearch_domain_arn = local.data_config.opensearch_domain_arn
  
  # Logging
  log_retention_days = var.log_retention_days

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "AI/ML"
    Service   = "Kendra"
    Purpose   = "IntelligentSearch"
    Features  = "RescoreExecution"
  }

  depends_on = [
    data.aws_ssm_parameter.data_config,
    data.aws_ssm_parameter.project_config_aiml
  ]
}

# =============================================================================
# Supporting Resources and Integration
# =============================================================================

# Lambda permission for S3 to invoke transcription function
resource "aws_lambda_permission" "s3_invoke_transcribe" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = local.compute_config_aiml.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.data_config.s3_bucket_arn
}

# Update project config with AI/ML service outputs
resource "aws_ssm_parameter" "aiml_config" {
  name  = "/${var.project_name}/config/aiml"
  type  = "String"
  value = jsonencode({
    # Bedrock Configuration
    bedrock_execution_role_arn = module.bedrock.bedrock_execution_role_arn
    bedrock_lambda_role_arn = module.bedrock.lambda_execution_role_arn
    bedrock_knowledge_base_role_arn = module.bedrock.knowledge_base_role_arn
    bedrock_log_group_name = module.bedrock.log_group_name
    bedrock_enabled_models = module.bedrock.enabled_models
    bedrock_embedding_model_id = module.bedrock.embedding_model_id
    bedrock_model_arns = module.bedrock.model_arns
    bedrock_claude_3_haiku_arn = module.bedrock.claude_3_haiku_arn
    bedrock_claude_3_5_sonnet_arn = module.bedrock.claude_3_5_sonnet_arn
    bedrock_claude_3_5_haiku_arn = module.bedrock.claude_3_5_haiku_arn
    bedrock_titan_embeddings_arn = module.bedrock.titan_text_embeddings_v2_arn
    
    # Transcribe Configuration
    transcribe_role_arn = module.transcribe.transcribe_role_arn
    transcribe_lambda_role_arn = module.transcribe.lambda_trigger_role_arn
    transcribe_log_group_name = module.transcribe.log_group_name
    transcribe_vocabulary_name = module.transcribe.custom_vocabulary_name
    
    # Kendra Configuration
    kendra_index_id = module.kendra.index_id
    kendra_index_arn = module.kendra.index_arn
    kendra_index_role_arn = module.kendra.index_role_arn
    kendra_s3_data_source_id = module.kendra.s3_data_source_id
    kendra_search_experience_id = module.kendra.search_experience_id
    kendra_lambda_role_arn = module.kendra.lambda_integration_role_arn
    kendra_log_group_name = module.kendra.log_group_name
  })

  tags = merge(local.mandatory_tags, {
    Name      = "${var.project_name}-aiml-config"
    Component = "Configuration"
    Purpose   = "CrossFileReference"
  })

  depends_on = [
    module.bedrock,
    module.transcribe,
    module.kendra
  ]
}

# CloudWatch Log Groups for AI/ML services
resource "aws_cloudwatch_log_group" "aiml_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/aiml"
  retention_in_days = var.log_retention_days

  tags = merge(local.mandatory_tags, {
    Name      = "${local.project_config_aiml.service_prefix}-aiml-logs-${var.environment}"
    Component = "Monitoring"
    Purpose   = "AIMLLogging"
    Service   = "CloudWatch"
  })
}

# IAM policy for cross-service integration
resource "aws_iam_policy" "aiml_integration_policy" {
  name        = "${local.project_config_aiml.service_prefix}-aiml-integration-policy-${var.environment}"
  description = "Policy for AI/ML services integration"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate"
        ]
        Resource = [
          module.bedrock.claude_3_haiku_arn,
          module.bedrock.claude_3_5_sonnet_arn,
          module.bedrock.claude_3_5_haiku_arn,
          module.bedrock.titan_text_embeddings_v2_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "transcribe:StartTranscriptionJob",
          "transcribe:GetTranscriptionJob",
          "transcribe:ListTranscriptionJobs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kendra:Query",
          "kendra:Retrieve",
          "kendra:SubmitFeedback",
          "kendra:GetQuerySuggestions"
        ]
        Resource = module.kendra.index_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          local.data_config.s3_bucket_arn,
          "${local.data_config.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpGet",
          "es:ESHttpPost",
          "es:ESHttpPut"
        ]
        Resource = "${local.data_config.opensearch_domain_arn}/*"
      }
    ]
  })

  tags = merge(local.mandatory_tags, {
    Name      = "${local.project_config_aiml.service_prefix}-aiml-integration-policy-${var.environment}"
    Component = "IAM"
    Purpose   = "AIMLIntegration"
  })
}

# Attach integration policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_aiml_integration" {
  policy_arn = aws_iam_policy.aiml_integration_policy.arn
  role       = local.compute_config_aiml.lambda_role_arn
}
