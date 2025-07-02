
# RDS PostgreSQL Configuration
module "rds_postgres" {
  source = "${local.module_source}rds_postgres"

  # Database Configuration
  db_identifier  = var.rds_db_identifier
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  # Storage Configuration
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = var.rds_storage_type
  storage_encrypted     = var.rds_storage_encrypted

  # Database Settings
  db_name    = var.rds_db_name
  db_username = var.rds_db_username

  # Network Configuration
  vpc_id              = var.vpc_id
  subnet_ids          = var.rds_subnet_ids
  publicly_accessible = var.rds_publicly_accessible

  # Backup and Maintenance
  backup_retention_period = var.rds_backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # High Availability
  multi_az = var.rds_multi_az

  # Monitoring
  monitoring_interval                   = var.rds_monitoring_interval
  performance_insights_enabled          = var.rds_performance_insights_enabled
  performance_insights_retention_period = 7

  # Parameter Group
  parameter_group_family = "postgres15"
  db_parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    }
  ]

  # Protection and Snapshots
  deletion_protection   = var.rds_deletion_protection
  skip_final_snapshot   = var.rds_skip_final_snapshot

  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["postgresql"]
  auto_minor_version_upgrade      = true

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
    Component   = "rds-postgres"
  }
}

# Outputs for RDS PostgreSQL
output "rds_db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds_postgres.db_instance_endpoint
  sensitive   = true
}

output "rds_db_instance_id" {
  description = "RDS instance ID"
  value       = module.rds_postgres.db_instance_id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.rds_postgres.db_security_group_id
}

output "rds_db_instance_arn" {
  description = "RDS instance ARN"
  value       = module.rds_postgres.db_instance_arn
}

output "rds_db_instance_port" {
  description = "RDS instance port"
  value       = module.rds_postgres.db_instance_port
}

output "rds_secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = module.rds_postgres.secrets_manager_secret_arn
}

output "rds_db_subnet_group_name" {
  description = "DB subnet group name"
  value       = module.rds_postgres.db_subnet_group_name
}
