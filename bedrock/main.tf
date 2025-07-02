
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

# CloudWatch Log Group for Bedrock model invocations
resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = "/aws/bedrock/${var.service_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(
    local.mandatory_tags,
    {
      Name        = "${var.service_name}-bedrock-logs"
      Purpose     = "Bedrock model invocation logging"
      Application = "Study Companion RAG"
    }
  )
}

# IAM Role for Bedrock service
resource "aws_iam_role" "bedrock_execution_role" {
  name        = "${var.service_name}-bedrock-execution-role"
  description = "IAM role for Bedrock service execution"

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
    local.mandatory_tags,
    {
      Name = "${var.service_name}-bedrock-execution-role"
    }
  )
}

# Continue with the rest of your Bedrock resources...
# Make sure to use local.mandatory_tags instead of var.mandatory_tags and var.additional_tags
