
# Glue Module
module "glue" {
  source = "../glue"

  database_name   = var.glue_database_name
  s3_bucket_name  = module.s3_bucket.bucket_id

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
