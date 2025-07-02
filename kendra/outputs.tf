
output "index_id" {
  description = "ID of the Kendra index"
  value       = aws_kendra_index.this.id
}

output "index_arn" {
  description = "ARN of the Kendra index"
  value       = aws_kendra_index.this.arn
}

output "index_name" {
  description = "Name of the Kendra index"
  value       = aws_kendra_index.this.name
}

output "index_role_arn" {
  description = "ARN of the Kendra index IAM role"
  value       = aws_iam_role.kendra_index_role.arn
}

output "s3_data_source_id" {
  description = "ID of the S3 data source (if created)"
  value       = var.create_s3_data_source ? aws_kendra_data_source.s3_data_source[0].id : null
}

output "s3_data_source_arn" {
  description = "ARN of the S3 data source (if created)"
  value       = var.create_s3_data_source ? aws_kendra_data_source.s3_data_source[0].arn : null
}

output "search_experience_id" {
  description = "ID of the search experience (if created)"
  value       = var.create_search_experience ? aws_kendra_experience.search_experience[0].id : null
}

output "search_experience_endpoint" {
  description = "Endpoint of the search experience (if created)"
  value       = var.create_search_experience ? aws_kendra_experience.search_experience[0].endpoint : null
}

output "lambda_integration_role_arn" {
  description = "ARN of the Lambda integration role (if created)"
  value       = var.create_lambda_integration_role ? aws_iam_role.lambda_kendra_role[0].arn : null
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.kendra_logs.name
}

output "log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.kendra_logs.arn
}

# Configuration outputs for application integration
output "kendra_config" {
  description = "Complete Kendra configuration for application integration"
  value = {
    index_id                = aws_kendra_index.this.id
    index_arn              = aws_kendra_index.this.arn
    index_name             = aws_kendra_index.this.name
    index_role_arn         = aws_iam_role.kendra_index_role.arn
    edition                = var.index_edition
    language_code          = var.language_code
    s3_data_source_enabled = var.create_s3_data_source
    search_experience_enabled = var.create_search_experience
    lambda_integration_enabled = var.create_lambda_integration_role
  }
}

# Search configuration
output "search_config" {
  description = "Search configuration details"
  value = {
    query_suggestions_enabled = var.enable_query_suggestions
    faceting_enabled         = var.enable_faceting
    ranking_enabled          = var.enable_ranking
    performance_monitoring   = var.enable_performance_monitoring
    cost_optimization       = var.enable_cost_optimization
  }
}

# Integration outputs
output "integration_config" {
  description = "Integration configuration for other services"
  value = {
    bedrock_integration     = var.bedrock_integration
    opensearch_integration  = var.opensearch_integration
    opensearch_domain_arn   = var.opensearch_domain_arn
    s3_bucket_arns         = var.s3_bucket_arns
  }
}
