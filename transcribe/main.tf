
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM Role for Transcribe Service
resource "aws_iam_role" "transcribe_role" {
  name = "${var.service_name}-transcribe-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "transcribe.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.service_name}-transcribe-role"
    }
  )
}

# IAM Policy for Transcribe S3 Access
resource "aws_iam_role_policy" "transcribe_s3_policy" {
  name = "${var.service_name}-transcribe-s3-policy"
  role = aws_iam_role.transcribe_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_role_policy" "transcribe_logs_policy" {
  name = "${var.service_name}-transcribe-logs-policy"
  role = aws_iam_role.transcribe_role.id

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
          aws_cloudwatch_log_group.transcribe_logs.arn,
          "${aws_cloudwatch_log_group.transcribe_logs.arn}:*"
        ]
      }
    ]
  })
}

# CloudWatch Log Group for Transcribe
resource "aws_cloudwatch_log_group" "transcribe_logs" {
  name              = "/aws/transcribe/${var.service_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.service_name}-transcribe-logs"
    }
  )
}

# Custom Vocabulary (optional)
resource "aws_transcribe_vocabulary" "custom_vocabulary" {
  count = var.create_custom_vocabulary ? 1 : 0

  vocabulary_name     = "${var.service_name}-vocabulary"
  language_code       = var.language_code
  vocabulary_file_uri = var.vocabulary_file_uri
  phrases             = var.vocabulary_phrases

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.service_name}-vocabulary"
    }
  )

  depends_on = [aws_iam_role_policy.transcribe_s3_policy]
}

# Language Model (optional)
resource "aws_transcribe_language_model" "custom_language_model" {
  count = var.create_language_model ? 1 : 0

  model_name      = "${var.service_name}-language-model"
  base_model_name = var.base_model_name
  language_code   = var.language_code

  input_data_config {
    s3_uri                    = var.language_model_data_s3_uri
    data_access_role_arn      = aws_iam_role.transcribe_role.arn
    tuning_data_s3_uri        = var.tuning_data_s3_uri
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.service_name}-language-model"
    }
  )

  depends_on = [aws_iam_role_policy.transcribe_s3_policy]
}

# S3 Bucket Notification for automatic transcription (optional)
resource "aws_s3_bucket_notification" "transcribe_notification" {
  count  = var.enable_s3_notifications ? 1 : 0
  bucket = var.s3_bucket_name

  dynamic "lambda_function" {
    for_each = var.lambda_function_arn != null ? [1] : []
    content {
      lambda_function_arn = var.lambda_function_arn
      events              = var.s3_notification_events
      filter_prefix       = var.s3_notification_filter_prefix
      filter_suffix       = var.s3_notification_filter_suffix
    }
  }

  dynamic "queue" {
    for_each = var.sqs_queue_arn != null ? [1] : []
    content {
      queue_arn = var.sqs_queue_arn
      events    = var.s3_notification_events
      filter_prefix = var.s3_notification_filter_prefix
      filter_suffix = var.s3_notification_filter_suffix
    }
  }

  depends_on = [aws_iam_role_policy.transcribe_s3_policy]
}

# IAM Role for Lambda function to trigger transcription jobs (optional)
resource "aws_iam_role" "transcribe_lambda_role" {
  count = var.create_lambda_trigger_role ? 1 : 0
  name  = "${var.service_name}-transcribe-lambda-role"

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
      Name = "${var.service_name}-transcribe-lambda-role"
    }
  )
}

# IAM Policy for Lambda to start transcription jobs
resource "aws_iam_role_policy" "transcribe_lambda_policy" {
  count = var.create_lambda_trigger_role ? 1 : 0
  name  = "${var.service_name}-transcribe-lambda-policy"
  role  = aws_iam_role.transcribe_lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "transcribe:StartTranscriptionJob",
          "transcribe:GetTranscriptionJob",
          "transcribe:ListTranscriptionJobs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count      = var.create_lambda_trigger_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.transcribe_lambda_role[0].name
}
