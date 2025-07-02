
# ECR Module
module "ecr" {
  source = "../ecr"

  repository_name = var.ecr_repository_name

  # Mandatory tags
  mandatory_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.contact_name
  }
  additional_tags = var.common_tags
}
