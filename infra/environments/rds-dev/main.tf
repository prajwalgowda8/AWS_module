
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
  project     = "sc-rds-postgres-demo"
  
  # Manually created VPC and subnet IDs (replace with your actual IDs)
  vpc_id = "vpc-0123456789abcdef0"
  
  # Private subnets for RDS instance (must be in different AZs for Multi-AZ)
  private_subnet_ids = [
    "subnet-0123456789abcdef3",
    "subnet-0123456789abcdef4"
  ]
  
  # Common tags for all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedDate = "2025-01-02"
  }
}

# RDS PostgreSQL Module
module "rds_postgres" {
  source = "../../rds_postgres"
  
  # Database configuration
  db_identifier  = "sc-rds-postgres-demo"
  engine_version = "15.4"
  instance_class = "db.m5.xlarge"
  
  # Storage configuration
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type          = "gp3"
  storage_encrypted     = true
  
  # Database settings
  db_name     = "postgres"
  db_username = "postgres"
  
  # Network configuration (manually created VPC/subnets)
  vpc_id             = local.vpc_id
  subnet_ids         = local.private_subnet_ids
  publicly_accessible = false
  
  # High availability and performance
  multi_az                              = true
  monitoring_interval                   = 60
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  
  # Backup configuration
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Security and compliance
  deletion_protection   = true
  skip_final_snapshot   = false
  
  # Database parameters
  db_parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name  = "log_statement"
      value = "all"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  ]
  
  # Mandatory tags
  common_tags                    = local.common_tags
  contact_group                  = "Database Team"
  contact_name                   = "Jane Smith"
  cost_bucket                    = "development"
  data_owner                     = "Data Engineering Team"
  display_name                   = "SC RDS PostgreSQL Demo Development"
  environment                    = local.environment
  has_public_ip                  = "false"
  has_unisys_network_connection  = "false"
  service_line                   = "Data Services"
}

# Output database information
output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds_postgres.db_instance_endpoint
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = module.rds_postgres.db_instance_id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = module.rds_postgres.db_instance_arn
}

output "db_port" {
  description = "RDS instance port"
  value       = module.rds_postgres.db_instance_port
}

output "db_name" {
  description = "Database name"
  value       = module.rds_postgres.db_name
}

output "db_security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = module.rds_postgres.db_security_group_id
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = module.rds_postgres.secrets_manager_secret_arn
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret containing database credentials"
  value       = module.rds_postgres.secrets_manager_secret_name
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = module.rds_postgres.db_subnet_group_name
}

output "db_parameter_group_name" {
  description = "DB parameter group name"
  value       = module.rds_postgres.db_parameter_group_name
}
