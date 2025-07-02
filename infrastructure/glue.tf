
# Note: Glue notebook will be uploaded manually

# AWS Glue Configuration
module "glue" {
  source = "${local.module_source}glue"

  # Database Configuration
  database_name   = var.glue_database_name
  s3_bucket_name  = var.s3_bucket_name

  # Glue Job Configuration
  glue_version        = var.glue_version
  worker_type         = var.glue_worker_type
  number_of_workers   = var.glue_number_of_workers

  # Job Settings
  enable_job_bookmarks      = var.glue_enable_job_bookmarks
  enable_metrics           = var.glue_enable_metrics
  enable_continuous_logging = var.glue_enable_continuous_logging

  # Logging Configuration
  log_group_retention_days = var.glue_log_group_retention_days

  # Glue Jobs Configuration (empty by default - can be configured later)
  glue_jobs = {}

  # Crawlers Configuration (empty by default - can be configured later)
  crawlers = {}

  # Connections Configuration (empty by default - can be configured later)
  connections = {}

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
    Component   = "glue-service"
  }
}

# Outputs for AWS Glue
output "glue_database_name" {
  description = "Name of the Glue catalog database"
  value       = module.glue.database_name
}

output "glue_database_arn" {
  description = "ARN of the Glue catalog database"
  value       = module.glue.database_arn
}

output "glue_role_arn" {
  description = "ARN of the Glue IAM role"
  value       = module.glue.glue_role_arn
}

output "glue_role_name" {
  description = "Name of the Glue IAM role"
  value       = module.glue.glue_role_name
}

output "glue_log_group_name" {
  description = "Name of the CloudWatch log group for Glue jobs"
  value       = module.glue.log_group_name
}

output "glue_log_group_arn" {
  description = "ARN of the CloudWatch log group for Glue jobs"
  value       = module.glue.log_group_arn
}

output "glue_version" {
  description = "Version of AWS Glue being used"
  value       = module.glue.glue_version
}

output "glue_worker_type" {
  description = "Worker type for Glue jobs"
  value       = module.glue.worker_type
}

output "glue_number_of_workers" {
  description = "Number of workers for Glue jobs"
  value       = module.glue.number_of_workers
}
