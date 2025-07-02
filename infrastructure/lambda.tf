
# Create a dummy Lambda deployment package
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "lambda_function.zip"
  source {
    content = <<EOF
def handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }
EOF
    filename = "index.py"
  }
}

# Lambda Module
module "lambda" {
  source = "../lambda"

  function_name = var.lambda_function_name
  runtime       = var.lambda_runtime
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  vpc_config = {
    vpc_id             = var.vpc_id
    subnet_ids         = var.private_subnet_ids
    security_group_ids = []
  }

  environment_variables = {
    S3_BUCKET = module.s3_bucket.bucket_id
    RDS_SECRET_ARN = module.secrets_manager.secret_arn
  }

  # Mandatory tags
  mandatory_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.contact_name
  }
  additional_tags = var.common_tags
}
