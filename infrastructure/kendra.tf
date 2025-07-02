
# Kendra Module
module "kendra" {
  source = "../kendra"

  index_name    = var.kendra_index_name
  index_edition = var.kendra_edition

  # Mandatory tags
  mandatory_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.contact_name
  }
  additional_tags = var.common_tags
}
