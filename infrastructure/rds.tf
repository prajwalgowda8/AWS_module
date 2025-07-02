
# RDS PostgreSQL Module
module "rds_postgres" {
  source = "../rds_postgres"

  db_identifier      = "${var.project_name}-${var.environment}-postgres"
  instance_class     = var.rds_instance_class
  allocated_storage  = var.rds_allocated_storage
  engine_version     = var.rds_engine_version
  db_name            = var.rds_database_name
  db_username        = var.rds_username
  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids

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
