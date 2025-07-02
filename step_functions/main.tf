
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions_role" {
  name = "${var.state_machine_name}-role"

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
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.state_machine_name}-role"
    }
  )
}

# Attach additional policies to the role
resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = length(var.additional_policy_arns)
  policy_arn = var.additional_policy_arns[count.index]
  role       = aws_iam_role.step_functions_role.name
}

# Custom inline policy for Step Functions
resource "aws_iam_role_policy" "step_functions_policy" {
  count = var.custom_policy != null ? 1 : 0
  name  = "${var.state_machine_name}-policy"
  role  = aws_iam_role.step_functions_role.id

  policy = var.custom_policy
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "step_functions_logs" {
  count             = var.enable_logging ? 1 : 0
  name              = "/aws/stepfunctions/${var.state_machine_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.state_machine_name}-logs"
    }
  )
}

# Step Functions State Machine
resource "aws_sfn_state_machine" "this" {
  name       = var.state_machine_name
  role_arn   = aws_iam_role.step_functions_role.arn
  definition = var.definition
  type       = var.type

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

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.state_machine_name
    }
  )
}
