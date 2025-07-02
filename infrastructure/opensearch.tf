
# OpenSearch Module
module "opensearch" {
  source = "../opensearch"

  domain_name      = var.opensearch_domain_name
  instance_type    = var.opensearch_instance_type
  instance_count   = var.opensearch_instance_count
  vpc_id           = var.vpc_id
  subnet_ids       = var.private_subnet_ids
  allowed_security_groups = [module.lambda.security_group_id]

  # Mandatory tags
  mandatory_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.contact_name
  }
  additional_tags = var.common_tags
}
