
# EKS Outputs
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

# RDS Outputs
output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.rds_postgres.db_instance_id
}

output "rds_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds_postgres.db_instance_endpoint
  sensitive   = true
}

output "rds_instance_port" {
  description = "RDS instance port"
  value       = module.rds_postgres.db_instance_port
}

# S3 Outputs
output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = module.s3_bucket.bucket_id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3_bucket.bucket_arn
}

# Lambda Outputs
output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = module.lambda.function_arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda.function_name
}

# Glue Outputs
output "glue_database_name" {
  description = "Glue catalog database name"
  value       = module.glue.database_name
}

output "glue_role_arn" {
  description = "Glue IAM role ARN"
  value       = module.glue.glue_role_arn
}

# Step Functions Outputs
output "step_functions_state_machine_arn" {
  description = "Step Functions state machine ARN"
  value       = module.step_functions.state_machine_arn
}

# Secrets Manager Outputs
output "rds_secret_arn" {
  description = "RDS credentials secret ARN"
  value       = module.secrets_manager.secret_arn
  sensitive   = true
}

# OpenSearch Outputs
output "opensearch_domain_arn" {
  description = "OpenSearch domain ARN"
  value       = module.opensearch.domain_arn
}

output "opensearch_domain_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = module.opensearch.endpoint
}

# Kendra Outputs
output "kendra_index_id" {
  description = "Kendra index ID"
  value       = module.kendra.index_id
}

output "kendra_index_arn" {
  description = "Kendra index ARN"
  value       = module.kendra.index_arn
}

# ECR Outputs
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}

# SES Outputs
output "ses_email_identities" {
  description = "SES email identities"
  value       = module.ses.email_identities
}

output "ses_configuration_set_name" {
  description = "SES configuration set name"
  value       = module.ses.configuration_set_name
}

# Bedrock Outputs
output "bedrock_execution_role_arn" {
  description = "Bedrock execution role ARN"
  value       = module.bedrock.bedrock_execution_role_arn
}

# CloudWatch Outputs
output "cloudwatch_sns_topic_arn" {
  description = "CloudWatch SNS topic ARN"
  value       = module.cloudwatch.sns_topic_arn
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups"
  value       = module.cloudwatch.log_groups
}
