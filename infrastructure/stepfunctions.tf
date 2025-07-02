
# Step Functions Module
module "step_functions" {
  source = "../step_functions"

  lambda_function_arn = module.lambda.function_arn
  
  project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
}
