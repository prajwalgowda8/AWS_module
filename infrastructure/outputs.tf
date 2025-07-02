
# EKS Outputs
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = try(module.eks[0].cluster_id, null)
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = try(module.eks[0].cluster_endpoint, null)
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = try(module.eks[0].cluster_security_group_id, null)
}

# RDS Outputs
output "rds_instance_id" {
  description = "RDS instance ID"
  value       = try(module.rds[0].instance_id, null)
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = try(module.rds[0].endpoint, null)
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = try(module.rds[0].port, null)
}

# S3 Outputs
output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = try(module.s3[0].bucket_id, null)
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = try(module.s3[0].bucket_arn, null)
}

# ECR Outputs
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = try(module.ecr[0].repository_url, null)
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = try(module.ecr[0].repository_arn, null)
}

# OpenSearch Outputs
output "opensearch_domain_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = try(module.opensearch[0].domain_endpoint, null)
}

output "opensearch_domain_arn" {
  description = "OpenSearch domain ARN"
  value       = try(module.opensearch[0].domain_arn, null)
}

# Lambda Outputs
output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = try(module.lambda[0].function_arn, null)
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = try(module.lambda[0].function_name, null)
}

# Secrets Manager Outputs
output "secrets_manager_secret_arn" {
  description = "Secrets Manager secret ARN"
  value       = try(module.secrets[0].secret_arn, null)
}

# Step Functions Outputs
output "step_functions_state_machine_arn" {
  description = "Step Functions state machine ARN"
  value       = try(module.step_functions[0].state_machine_arn, null)
}

# CloudWatch Outputs
output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = try(module.cloudwatch[0].log_group_name, null)
}

# Bedrock Outputs
output "bedrock_model_id" {
  description = "Bedrock model ID"
  value       = try(module.bedrock[0].model_id, null)
}

# Glue Outputs
output "glue_job_name" {
  description = "Glue job name"
  value       = try(module.glue[0].job_name, null)
}

# SES Outputs
output "ses_domain_identity" {
  description = "SES domain identity"
  value       = try(module.ses[0].domain_identity, null)
}

# Kendra Outputs
output "kendra_index_id" {
  description = "Kendra index ID"
  value       = try(module.kendra[0].index_id, null)
}

# CloudTrail Outputs
output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = try(module.cloudtrail[0].trail_arn, null)
}

# DocumentDB Outputs
output "documentdb_cluster_endpoint" {
  description = "DocumentDB cluster endpoint"
  value       = try(module.documentdb[0].cluster_endpoint, null)
  sensitive   = true
}
