
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

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
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.function_name}-role"
    }
  )
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Attach VPC execution policy if VPC is configured
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count      = var.vpc_config != null ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Attach additional policies
resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = length(var.additional_policy_arns)
  policy_arn = var.additional_policy_arns[count.index]
  role       = aws_iam_role.lambda_role.name
}

# Security Group for Lambda (if VPC is configured)
resource "aws_security_group" "lambda_sg" {
  count       = var.vpc_config != null ? 1 : 0
  name_prefix = "${var.function_name}-lambda-sg"
  vpc_id      = var.vpc_config.vpc_id
  description = "Security group for Lambda function ${var.function_name}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.function_name}-lambda-sg"
    }
  )
}

# Lambda Function
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role         = aws_iam_role.lambda_role.arn
  
  # Code configuration
  filename         = var.filename
  s3_bucket        = var.s3_bucket
  s3_key          = var.s3_key
  s3_object_version = var.s3_object_version
  image_uri       = var.image_uri
  source_code_hash = var.source_code_hash
  
  # Runtime configuration
  package_type = var.package_type
  runtime      = var.runtime
  handler      = var.handler
  architectures = var.architectures
  
  # Performance configuration
  memory_size = var.memory_size
  timeout     = var.timeout
  
  # Environment variables
  dynamic "environment" {
    for_each = var.environment_variables != null ? [var.environment_variables] : []
    content {
      variables = environment.value
    }
  }
  
  # VPC configuration
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = concat(
        vpc_config.value.security_group_ids,
        aws_security_group.lambda_sg[*].id
      )
    }
  }
  
  # Dead letter configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config != null ? [var.dead_letter_config] : []
    content {
      target_arn = dead_letter_config.value.target_arn
    }
  }
  
  # Tracing configuration
  dynamic "tracing_config" {
    for_each = var.tracing_config != null ? [var.tracing_config] : []
    content {
      mode = tracing_config.value.mode
    }
  }
  
  # Layers
  layers = var.layers
  
  # KMS key for environment variables
  kms_key_arn = var.kms_key_arn
  
  # Ephemeral storage
  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size != null ? [var.ephemeral_storage_size] : []
    content {
      size = ephemeral_storage.value
    }
  }
  
  # Reserved concurrent executions
  reserved_concurrent_executions = var.reserved_concurrent_executions
  
  # Publishing
  publish = var.publish
  
  description = var.description
  
  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.function_name
    }
  )
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id       = var.log_kms_key_id

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.function_name}-logs"
    }
  )
}
