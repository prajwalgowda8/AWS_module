
# EKS Module
module "eks" {
  source = "../eks"

  cluster_name               = var.eks_cluster_name
  vpc_id                     = var.vpc_id
  subnet_ids                 = concat(var.private_subnet_ids, var.public_subnet_ids)
  private_subnet_ids         = var.private_subnet_ids
  instance_types             = var.eks_instance_types
  desired_size               = var.eks_desired_size
  max_size                   = var.eks_max_size
  min_size                   = var.eks_min_size

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
