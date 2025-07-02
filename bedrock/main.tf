
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source to get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# CloudWatch Log Group for Bedrock model invocations
resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = "/aws/bedrock/${var.service_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.service_name}-bedrock-logs"
    }
  )
}

# IAM Role for Bedrock service
resource "aws_iam_role" "bedrock_execution_role" {
  name = "${var.service_name}-bedrock-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.service_name}-bedrock-execution-role"
    }
  )
}

# IAM Policy for Bedrock model access
resource "aws_iam_role_policy" "bedrock_model_access" {
  name = "${var.service_name}-bedrock-model-access"
  role = aws_iam_role.bedrock_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          for model in var.enabled_models : 
          "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${model}"
        ]
      }
    ]
  })
}

# IAM Policy for CloudWatch logging
resource "aws_iam_role_policy" "bedrock_logging" {
  name = "${var.service_name}-bedrock-logging"
  role = aws_iam_role.bedrock_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          aws_cloudwatch_log_group.bedrock_logs.arn,
          "${aws_cloudwatch_log_group.bedrock_logs.arn}:*"
        ]
      }
    ]
  })
}

# IAM Role for Knowledge Base
resource "aws_iam_role" "knowledge_base_role" {
  count = var.create_knowledge_base ? 1 : 0
  name  = "${var.service_name}-knowledge-base-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
          }
        }
      }
    ]
  })

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.service_name}-knowledge-base-role"
    }
  )
}

# IAM Policy for Knowledge Base S3 access
resource "aws_iam_role_policy" "knowledge_base_s3_access" {
  count = var.create_knowledge_base ? 1 : 0
  name  = "${var.service_name}-knowledge-base-s3-access"
  role  = aws_iam_role.knowledge_base_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.knowledge_base_s3_bucket_arn,
          "${var.knowledge_base_s3_bucket_arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# IAM Policy for Knowledge Base OpenSearch access
resource "aws_iam_role_policy" "knowledge_base_opensearch_access" {
  count = var.create_knowledge_base && var.vector_store_type == "opensearch" ? 1 : 0
  name  = "${var.service_name}-knowledge-base-opensearch-access"
  role  = aws_iam_role.knowledge_base_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aoss:APIAccessAll"
        ]
        Resource = var.opensearch_collection_arn
      }
    ]
  })
}

# IAM Policy for Knowledge Base embedding model access
resource "aws_iam_role_policy" "knowledge_base_embedding_access" {
  count = var.create_knowledge_base ? 1 : 0
  name  = "${var.service_name}-knowledge-base-embedding-access"
  role  = aws_iam_role.knowledge_base_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model_id}"
      }
    ]
  })
}

# IAM Role for Lambda functions using Bedrock
resource "aws_iam_role" "bedrock_lambda_role" {
  count = var.create_lambda_execution_role ? 1 : 0
  name  = "${var.service_name}-bedrock-lambda-role"

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
      Name = "${var.service_name}-bedrock-lambda-role"
    }
  )
}

# IAM Policy for Lambda Bedrock access
resource "aws_iam_role_policy" "lambda_bedrock_access" {
  count = var.create_lambda_execution_role ? 1 : 0
  name  = "${var.service_name}-lambda-bedrock-access"
  role  = aws_iam_role.bedrock_lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate"
        ]
        Resource = [
          for model in var.enabled_models : 
          "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${model}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate"
        ]
        Resource = var.create_knowledge_base ? "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*" : "*"
      }
    ]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count      = var.create_lambda_execution_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.bedrock_lambda_role[0].name
}

# Bedrock Model Invocation Logging Configuration
resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  count = var.enable_model_invocation_logging ? 1 : 0

  logging_config {
    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.bedrock_logs.name
      role_arn       = aws_iam_role.bedrock_execution_role.arn
    }

    embedding_data_delivery_enabled = var.log_embedding_data
    image_data_delivery_enabled     = var.log_image_data
    text_data_delivery_enabled      = var.log_text_data
  }
}

# CloudWatch Dashboard for Bedrock monitoring
resource "aws_cloudwatch_dashboard" "bedrock_dashboard" {
  count          = var.create_cloudwatch_dashboard ? 1 : 0
  dashboard_name = "${var.service_name}-bedrock-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Bedrock", "Invocations", "ModelId", var.enabled_models[0]],
            [".", "InputTokenCount", ".", "."],
            [".", "OutputTokenCount", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Bedrock Model Invocations"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Bedrock", "InvocationLatency", "ModelId", var.enabled_models[0]],
            [".", "InvocationClientErrors", ".", "."],
            [".", "InvocationServerErrors", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Bedrock Performance Metrics"
          period  = 300
        }
      }
    ]
  })
}

# CloudWatch Alarms for Bedrock monitoring
resource "aws_cloudwatch_metric_alarm" "bedrock_error_rate" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-bedrock-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "InvocationClientErrors"
  namespace           = "AWS/Bedrock"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.error_rate_threshold
  alarm_description   = "This metric monitors Bedrock client error rate"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ModelId = var.enabled_models[0]
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.service_name}-bedrock-error-rate-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "bedrock_latency" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-bedrock-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "InvocationLatency"
  namespace           = "AWS/Bedrock"
  period              = "300"
  statistic           = "Average"
  threshold           = var.latency_threshold
  alarm_description   = "This metric monitors Bedrock invocation latency"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ModelId = var.enabled_models[0]
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.service_name}-bedrock-latency-alarm"
    }
  )
}

# Provisioned Model Throughput (optional for high-volume applications)
resource "aws_bedrock_provisioned_model_throughput" "this" {
  count = var.create_provisioned_throughput ? 1 : 0

  provisioned_model_name = "${var.service_name}-provisioned-model"
  model_arn             = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.provisioned_model_id}"
  model_units           = var.provisioned_model_units
  commitment_duration   = var.provisioned_commitment_duration

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.service_name}-provisioned-model"
    }
  )
}
