
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Local tags configuration
locals {
  mandatory_tags = merge(var.common_tags, {
    contactGroup                = var.contact_group
    contactName                 = var.contact_name
    costBucket                  = var.cost_bucket
    dataOwner                   = var.data_owner
    displayName                 = var.display_name
    environment                 = var.environment
    hasPublicIP                 = var.has_public_ip
    hasUnisysNetworkConnection  = var.has_unisys_network_connection
    serviceLine                 = var.service_line
  })
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "step_functions_logs" {
  count             = var.enable_logging ? 1 : 0
  name              = "/aws/stepfunctions/${var.state_machine_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_encryption ? var.kms_key_id : null

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.state_machine_name}-logs"
    }
  )
}

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions_role" {
  name        = "${var.state_machine_name}-role"
  description = "IAM role for Step Functions state machine ${var.state_machine_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.state_machine_name}-role"
    }
  )
}

# Basic CloudWatch Logs policy for Step Functions
resource "aws_iam_role_policy" "step_functions_logs_policy" {
  count = var.enable_logging ? 1 : 0
  name  = "${var.state_machine_name}-logs-policy"
  role  = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# X-Ray tracing policy for Step Functions
resource "aws_iam_role_policy" "step_functions_xray_policy" {
  count = var.enable_tracing ? 1 : 0
  name  = "${var.state_machine_name}-xray-policy"
  role  = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ]
        Resource = "*"
      }
    ]
  })
}

# Lambda invocation policy
resource "aws_iam_role_policy" "step_functions_lambda_policy" {
  count = length(var.lambda_functions) > 0 ? 1 : 0
  name  = "${var.state_machine_name}-lambda-policy"
  role  = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [for arn in values(var.lambda_functions) : arn]
      }
    ]
  })
}

# SNS publish policy
resource "aws_iam_role_policy" "step_functions_sns_policy" {
  count = length(var.sns_topics) > 0 ? 1 : 0
  name  = "${var.state_machine_name}-sns-policy"
  role  = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.sns_topics
      }
    ]
  })
}

# SQS send message policy
resource "aws_iam_role_policy" "step_functions_sqs_policy" {
  count = length(var.sqs_queues) > 0 ? 1 : 0
  name  = "${var.state_machine_name}-sqs-policy"
  role  = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = var.sqs_queues
      }
    ]
  })
}

# S3 access policy
resource "aws_iam_role_policy" "step_functions_s3_policy" {
  count = length(var.s3_buckets) > 0 ? 1 : 0
  name  = "${var.state_machine_name}-s3-policy"
  role  = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = concat(
          var.s3_buckets,
          [for bucket in var.s3_buckets : "${bucket}/*"]
        )
      }
    ]
  })
}

# Attach additional policies to the role
resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = length(var.additional_policy_arns)
  policy_arn = var.additional_policy_arns[count.index]
  role       = aws_iam_role.step_functions_role.name
}

# Custom inline policy for Step Functions
resource "aws_iam_role_policy" "step_functions_custom_policy" {
  count = var.custom_policy != null ? 1 : 0
  name  = "${var.state_machine_name}-custom-policy"
  role  = aws_iam_role.step_functions_role.id

  policy = var.custom_policy
}

# Step Functions State Machine
resource "aws_sfn_state_machine" "this" {
  name       = var.state_machine_name
  role_arn   = aws_iam_role.step_functions_role.arn
  definition = var.definition
  type       = var.type
  publish    = var.publish_version

  dynamic "logging_configuration" {
    for_each = var.enable_logging ? [1] : []
    content {
      log_destination        = "${aws_cloudwatch_log_group.step_functions_logs[0].arn}:*"
      include_execution_data = var.include_execution_data
      level                  = var.log_level
    }
  }

  dynamic "tracing_configuration" {
    for_each = var.enable_tracing ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "encryption_configuration" {
    for_each = var.enable_encryption ? [1] : []
    content {
      kms_key_id                = var.kms_key_id
      kms_data_key_reuse_period_seconds = 300
      type                      = "CUSTOMER_MANAGED_KMS_KEY"
    }
  }

  tags = merge(
    local.mandatory_tags,
    {
      Name = var.state_machine_name
      Type = var.type
    }
  )
}
