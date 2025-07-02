
# Secrets Manager Module for RDS credentials
module "secrets_manager" {
  source = "../secrets_manager"

  secret_name        = "${var.project_name}-${var.environment}-rds-credentials"
  secret_description = "RDS PostgreSQL credentials for ${var.project_name}"
  
  database_config = {
    engine   = "postgres"
    host     = module.rds_postgres.db_instance_endpoint
    port     = module.rds_postgres.db_instance_port
    dbname   = var.rds_database_name
    username = var.rds_username
    password = "placeholder" # Will be updated after RDS creation
  }

  # Mandatory tags
  common_tags                        = var.common_tags
  contact_group                      = var.contact_group
  contact_name                       = var.contact_name
  cost_bucket                        = var.cost_bucket
  data_owner                         = var.data_owner
  display_name                       = var.display_name
  environment                        = var.environment
  has_public_ip                      = var.has_public_ip
  has_unisys_network_connection      = var.has_unisys_network_connection
  service_line                       = var.service_line
}
