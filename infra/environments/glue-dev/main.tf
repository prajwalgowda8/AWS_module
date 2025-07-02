
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
  project     = "sc-glue-demo"
  
  # S3 bucket for Glue scripts and data
  s3_bucket_name = "sc-glue-demo-${local.environment}-${random_id.bucket_suffix.hex}"
  
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

# S3 bucket for Glue scripts and data
resource "aws_s3_bucket" "glue_bucket" {
  bucket        = local.s3_bucket_name
  force_destroy = true

  tags = merge(
    local.common_tags,
    {
      Name = local.s3_bucket_name
      Purpose = "Glue scripts and data storage"
    }
  )
}

resource "aws_s3_bucket_versioning" "glue_bucket" {
  bucket = aws_s3_bucket.glue_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "glue_bucket" {
  bucket = aws_s3_bucket.glue_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create folders in S3 bucket for organization
resource "aws_s3_object" "scripts_folder" {
  bucket = aws_s3_bucket.glue_bucket.id
  key    = "scripts/"
  content = ""
  tags = local.common_tags
}

resource "aws_s3_object" "data_folder" {
  bucket = aws_s3_bucket.glue_bucket.id
  key    = "data/"
  content = ""
  tags = local.common_tags
}

resource "aws_s3_object" "temp_folder" {
  bucket = aws_s3_bucket.glue_bucket.id
  key    = "temp/"
  content = ""
  tags = local.common_tags
}

# AWS Glue Module
module "glue" {
  source = "../../glue"
  
  # Database configuration
  database_name = "sc-glue-demo"
  s3_bucket_name = aws_s3_bucket.glue_bucket.id
  
  # Glue job configuration
  glue_version        = "5.0"
  worker_type         = "G.1X"
  number_of_workers   = 5
  
  # Job settings
  enable_job_bookmarks      = true
  enable_metrics           = true
  enable_continuous_logging = true
  log_group_retention_days = 14
  
  # Sample Glue jobs configuration
  glue_jobs = {
    data_processing = {
      description     = "Data processing job for sc-glue-demo"
      script_location = "s3://${aws_s3_bucket.glue_bucket.id}/scripts/data_processing.py"
      python_version  = "3"
      max_concurrent_runs = 1
      max_retries        = 2
      timeout           = 2880
      default_arguments = {
        "--TempDir" = "s3://${aws_s3_bucket.glue_bucket.id}/temp/"
        "--job-language" = "python"
      }
    }
    etl_pipeline = {
      description     = "ETL pipeline job for sc-glue-demo"
      script_location = "s3://${aws_s3_bucket.glue_bucket.id}/scripts/etl_pipeline.py"
      python_version  = "3"
      max_concurrent_runs = 1
      max_retries        = 1
      timeout           = 1440
      default_arguments = {
        "--TempDir" = "s3://${aws_s3_bucket.glue_bucket.id}/temp/"
        "--job-language" = "python"
      }
    }
  }
  
  # Sample crawler configuration
  crawlers = {
    s3_data_crawler = {
      description  = "Crawler for S3 data in sc-glue-demo"
      schedule     = "cron(0 2 * * ? *)"
      table_prefix = "crawled_"
      s3_targets = [
        {
          path = "s3://${aws_s3_bucket.glue_bucket.id}/data/"
          exclusions = ["*.tmp", "*.log"]
        }
      ]
    }
  }
  
  # Mandatory tags
  common_tags                    = local.common_tags
  contact_group                  = "Data Engineering Team"
  contact_name                   = "Sarah Wilson"
  cost_bucket                    = "development"
  data_owner                     = "Analytics Team"
  display_name                   = "SC Glue Demo Development"
  environment                    = local.environment
  has_public_ip                  = "false"
  has_unisys_network_connection  = "false"
  service_line                   = "Data Processing Services"
}

# Output Glue information
output "database_name" {
  description = "Name of the Glue catalog database"
  value       = module.glue.database_name
}

output "database_arn" {
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

output "job_names" {
  description = "Names of the Glue jobs"
  value       = module.glue.job_names
}

output "job_arns" {
  description = "ARNs of the Glue jobs"
  value       = module.glue.job_arns
}

output "crawler_names" {
  description = "Names of the Glue crawlers"
  value       = module.glue.crawler_names
}

output "crawler_arns" {
  description = "ARNs of the Glue crawlers"
  value       = module.glue.crawler_arns
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Glue scripts and data"
  value       = aws_s3_bucket.glue_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Glue scripts and data"
  value       = aws_s3_bucket.glue_bucket.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for Glue jobs"
  value       = module.glue.log_group_name
}

output "glue_version" {
  description = "Version of AWS Glue being used"
  value       = module.glue.glue_version
}

output "worker_type" {
  description = "Worker type for Glue jobs"
  value       = module.glue.worker_type
}

output "number_of_workers" {
  description = "Number of workers for Glue jobs"
  value       = module.glue.number_of_workers
}
