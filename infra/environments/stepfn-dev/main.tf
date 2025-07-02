
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Local values for environment-specific configuration
locals {
  environment = "dev"
  project     = "sc-stepfn-demo"
  
  # Common tags for all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedDate = "2025-01-02"
  }
  
  # Sample Step Functions definition
  step_function_definition = jsonencode({
    Comment = "A simple Step Functions workflow for sc-stepfn-demo"
    StartAt = "HelloWorld"
    States = {
      HelloWorld = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.hello_world.function_name
          Payload = {
            "message" = "Hello from Step Functions!"
          }
        }
        Next = "ProcessData"
      }
      ProcessData = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.process_data.function_name
          Payload.$    = "$"
        }
        Next = "Choice"
      }
      Choice = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$.status"
            StringEquals = "success"
            Next = "Success"
          }
        ]
        Default = "Failure"
      }
      Success = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = aws_sns_topic.notifications.arn
          Message  = "Workflow completed successfully"
        }
        End = true
      }
      Failure = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = aws_sns_topic.notifications.arn
          Message  = "Workflow failed"
        }
        End = true
      }
    }
  })
}

# SNS Topic for notifications
resource "aws_sns_topic" "notifications" {
  name = "${local.project}-notifications"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project}-notifications"
    }
  )
}

# IAM role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${local.project}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project}-lambda-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Create Lambda deployment packages
data "archive_file" "hello_world_zip" {
  type        = "zip"
  output_path = "hello_world.zip"
  source {
    content = <<EOF
import json

def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from Lambda!',
            'input': event,
            'status': 'success'
        })
    }
EOF
    filename = "lambda_function.py"
  }
}

data "archive_file" "process_data_zip" {
  type        = "zip"
  output_path = "process_data.zip"
  source {
    content = <<EOF
import json
import random

def lambda_handler(event, context):
    print(f"Processing data: {json.dumps(event)}")
    
    # Simulate data processing
    success = random.choice([True, False])
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Data processed',
            'input': event,
            'status': 'success' if success else 'failure',
            'processed_at': context.aws_request_id
        }),
        'status': 'success' if success else 'failure'
    }
EOF
    filename = "lambda_function.py"
  }
}

# Sample Lambda function - Hello World
resource "aws_lambda_function" "hello_world" {
  filename         = data.archive_file.hello_world_zip.output_path
  function_name    = "${local.project}-hello-world"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.hello_world_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 30

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project}-hello-world"
    }
  )
}

# Sample Lambda function - Process Data
resource "aws_lambda_function" "process_data" {
  filename         = data.archive_file.process_data_zip.output_path
  function_name    = "${local.project}-process-data"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.process_data_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 60

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project}-process-data"
    }
  )
}

# Step Functions Module
module "step_functions" {
  source = "../../step_functions"
  
  # State machine configuration
  state_machine_name = "sc-stepfn-demo"
  definition         = local.step_function_definition
  type              = "STANDARD"
  
  # Logging and monitoring
  enable_logging           = true
  log_level               = "ALL"
  include_execution_data  = true
  log_retention_days      = 14
  enable_tracing          = true
  
  # Encryption
  enable_encryption = true
  
  # Permissions for AWS services
  lambda_functions = {
    hello_world  = aws_lambda_function.hello_world.arn
    process_data = aws_lambda_function.process_data.arn
  }
  
  sns_topics = [
    aws_sns_topic.notifications.arn
  ]
  
  # Mandatory tags
  common_tags                    = local.common_tags
  contact_group                  = "Workflow Team"
  contact_name                   = "Alex Thompson"
  cost_bucket                    = "development"
  data_owner                     = "Process Automation Team"
  display_name                   = "SC Step Functions Demo Development"
  environment                    = local.environment
  has_public_ip                  = "false"
  has_unisys_network_connection  = "false"
  service_line                   = "Workflow Services"
}

# Output Step Functions information
output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = module.step_functions.state_machine_arn
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = module.step_functions.state_machine_name
}

output "state_machine_status" {
  description = "Status of the Step Functions state machine"
  value       = module.step_functions.state_machine_status
}

output "state_machine_type" {
  description = "Type of the Step Functions state machine"
  value       = module.step_functions.state_machine_type
}

output "role_arn" {
  description = "ARN of the IAM role for the Step Functions state machine"
  value       = module.step_functions.role_arn
}

output "role_name" {
  description = "Name of the IAM role for the Step Functions state machine"
  value       = module.step_functions.role_name
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.step_functions.log_group_name
}

output "log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = module.step_functions.log_group_arn
}

output "lambda_function_arns" {
  description = "ARNs of the Lambda functions"
  value = {
    hello_world  = aws_lambda_function.hello_world.arn
    process_data = aws_lambda_function.process_data.arn
  }
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = aws_sns_topic.notifications.arn
}

output "logging_enabled" {
  description = "Whether CloudWatch logging is enabled"
  value       = module.step_functions.logging_enabled
}

output "tracing_enabled" {
  description = "Whether X-Ray tracing is enabled"
  value       = module.step_functions.tracing_enabled
}

output "encryption_enabled" {
  description = "Whether encryption is enabled"
  value       = module.step_functions.encryption_enabled
}
