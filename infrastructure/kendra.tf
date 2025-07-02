
# Kendra Search Service Configuration
module "kendra" {
  source = "${local.module_source}kendra"

  # Index Configuration
  index_name        = "MyKendraRankingPlan"
  index_description = "Kendra search index for document search and retrieval with ranking capabilities"
  index_edition     = "DEVELOPER_EDITION"

  # Language Configuration
  language_code = "en"

  # Capacity Configuration (null for DEVELOPER_EDITION)
  capacity_units = null

  # Security Configuration
  kms_key_id                = null
  user_context_policy       = null
  user_group_resolution_mode = null

  # User Token Configuration (empty by default)
  user_token_configurations = []

  # Document Metadata Configuration (empty by default)
  document_metadata_configurations = []

  # S3 Data Source Configuration (disabled by default)
  create_s3_data_source           = false
  s3_data_source_description      = "S3 data source for Kendra index"
  s3_data_source_bucket_name      = null
  s3_bucket_arns                  = []
  s3_data_source_schedule         = null
  s3_inclusion_prefixes           = null
  s3_exclusion_patterns           = null
  s3_documents_metadata_configuration = null
  s3_access_control_list_configuration = null

  # Custom Data Sources (empty by default)
  custom_data_sources = {}

  # FAQ Configuration (empty by default)
  faqs = {}

  # Thesaurus Configuration (empty by default)
  thesaurus_configurations = {}

  # Query Suggestions Block List (empty by default)
  query_suggestions_block_lists = {}

  # Search Experience Configuration (disabled by default)
  create_search_experience        = false
  search_experience_description   = "Kendra search experience for document search"
  search_experience_role_arn      = null
  search_experience_configuration = null

  # Lambda Integration
  create_lambda_integration_role = false

  # Logging Configuration
  log_retention_days = 14
  log_kms_key_id     = null

  # Ranking Configuration
  enable_ranking     = true
  ranking_plan_name  = "MyKendraRankingPlan"

  # Query Suggestions Configuration
  enable_query_suggestions = true
  query_suggestions_mode   = "ENABLED"

  # Faceting Configuration
  enable_faceting       = true
  facet_configurations  = []

  # Integration Configuration
  bedrock_integration      = false
  opensearch_integration   = false
  opensearch_domain_arn    = null

  # Performance Configuration
  enable_performance_monitoring = true
  query_timeout_seconds         = 30

  # Cost Optimization
  enable_cost_optimization = true
  auto_scaling_enabled     = false

  # Mandatory Tags (Kendra module uses different tag structure)
  mandatory_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.contact_name
    contactGroup                = var.contact_group
    contactName                 = var.contact_name
    costBucket                  = var.cost_bucket
    dataOwner                   = var.data_owner
    displayName                 = var.display_name
    hasPublicIP                 = var.has_public_ip
    hasUnisysNetworkConnection  = var.has_unisys_network_connection
    serviceLine                 = var.service_line
  }

  # Additional tags
  additional_tags = {
    Component   = "kendra-search"
    ManagedBy   = "terraform"
    Region      = var.region
  }
}

# Outputs for Kendra
output "kendra_index_id" {
  description = "ID of the Kendra index"
  value       = module.kendra.index_id
}

output "kendra_index_arn" {
  description = "ARN of the Kendra index"
  value       = module.kendra.index_arn
}

output "kendra_index_name" {
  description = "Name of the Kendra index"
  value       = module.kendra.index_name
}

output "kendra_index_role_arn" {
  description = "ARN of the Kendra index IAM role"
  value       = module.kendra.index_role_arn
}

output "kendra_log_group_name" {
  description = "CloudWatch log group name"
  value       = module.kendra.log_group_name
}

output "kendra_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = module.kendra.log_group_arn
}

output "kendra_config" {
  description = "Complete Kendra configuration for application integration"
  value       = module.kendra.kendra_config
}

output "kendra_search_config" {
  description = "Search configuration details"
  value       = module.kendra.search_config
}

output "kendra_integration_config" {
  description = "Integration configuration for other services"
  value       = module.kendra.integration_config
}
