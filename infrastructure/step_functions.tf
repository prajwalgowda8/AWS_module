
# Step Functions Module
module "step_functions" {
  source = "../step_functions"

  state_machine_name = "${var.project_name}-${var.environment}-state-machine"
  definition         = var.step_functions_definition

  lambda_functions = {
    main_function = module.lambda.function_arn
  }

  s3_buckets = [
    module.s3_bucket.bucket_arn
  ]

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
