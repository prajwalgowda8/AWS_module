
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM Role for CloudTrail CloudWatch Logs
resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  count = var.cloudwatch_log_group_arn != null ? 1 : 0
  name  = "${var.trail_name}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.trail_name}-cloudwatch-role"
    }
  )
}

# IAM Policy for CloudTrail CloudWatch Logs
resource "aws_iam_role_policy" "cloudtrail_cloudwatch_policy" {
  count = var.cloudwatch_log_group_arn != null ? 1 : 0
  name  = "${var.trail_name}-cloudwatch-policy"
  role  = aws_iam_role.cloudtrail_cloudwatch_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "${var.cloudwatch_log_group_arn}:*"
      }
    ]
  })
}

# CloudTrail
resource "aws_cloudtrail" "this" {
  name           = var.trail_name
  s3_bucket_name = var.s3_bucket_name
  s3_key_prefix  = var.s3_key_prefix

  enable_log_file_validation    = var.enable_log_file_validation
  enable_logging               = var.enable_logging
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail        = var.is_multi_region_trail
  is_organization_trail        = var.is_organization_trail

  cloud_watch_logs_group_arn = var.cloudwatch_log_group_arn
  cloud_watch_logs_role_arn  = var.cloudwatch_log_group_arn != null ? aws_iam_role.cloudtrail_cloudwatch_role[0].arn : null

  kms_key_id = var.kms_key_id

  dynamic "event_selector" {
    for_each = var.event_selectors
    content {
      read_write_type                 = event_selector.value.read_write_type
      include_management_events       = event_selector.value.include_management_events
      exclude_management_event_sources = event_selector.value.exclude_management_event_sources

      dynamic "data_resource" {
        for_each = event_selector.value.data_resources
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.trail_name
    }
  )

  depends_on = [aws_iam_role_policy.cloudtrail_cloudwatch_policy]
}
