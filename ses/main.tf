
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
  
  configuration_set_name = var.configuration_set_name != null ? var.configuration_set_name : "${var.service_name}-config-set"
  bounce_topic_name      = var.bounce_topic_name != null ? var.bounce_topic_name : "${var.service_name}-bounces"
  complaint_topic_name   = var.complaint_topic_name != null ? var.complaint_topic_name : "${var.service_name}-complaints"
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# SES Email Identities
resource "aws_ses_email_identity" "email_addresses" {
  for_each = toset(var.email_addresses)
  email    = each.value
}

# SES Domain Identity (optional)
resource "aws_ses_domain_identity" "domain" {
  count  = var.domain_name != null ? 1 : 0
  domain = var.domain_name
}

# SES Domain DKIM (optional)
resource "aws_ses_domain_dkim" "domain_dkim" {
  count  = var.domain_name != null ? 1 : 0
  domain = aws_ses_domain_identity.domain[0].domain
}

# SES Domain Mail From (optional)
resource "aws_ses_domain_mail_from" "domain_mail_from" {
  count            = var.domain_name != null && var.mail_from_domain != null ? 1 : 0
  domain           = aws_ses_domain_identity.domain[0].domain
  mail_from_domain = var.mail_from_domain
}

# CloudWatch Log Group for SES
resource "aws_cloudwatch_log_group" "ses_logs" {
  count             = var.enable_cloudwatch_destination ? 1 : 0
  name              = "/aws/ses/${var.service_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(
    local.mandatory_tags,
    {
      Name    = "${var.service_name}-ses-logs"
      Purpose = "SES email service logging"
    }
  )
}

# SNS Topics for Bounce and Complaint Notifications
resource "aws_sns_topic" "bounce_notifications" {
  count = var.enable_bounce_topic ? 1 : 0
  name  = local.bounce_topic_name

  tags = merge(
    local.mandatory_tags,
    {
      Name    = local.bounce_topic_name
      Purpose = "SES bounce notifications"
    }
  )
}

resource "aws_sns_topic" "complaint_notifications" {
  count = var.enable_complaint_topic ? 1 : 0
  name  = local.complaint_topic_name

  tags = merge(
    local.mandatory_tags,
    {
      Name    = local.complaint_topic_name
      Purpose = "SES complaint notifications"
    }
  )
}

# SES Configuration Set
resource "aws_ses_configuration_set" "main" {
  count = var.create_configuration_set ? 1 : 0
  name  = local.configuration_set_name

  delivery_options {
    tls_policy = var.tls_policy
  }

  reputation_metrics_enabled = var.reputation_metrics_enabled
  sending_enabled            = var.sending_enabled
}

# SES Event Destination - CloudWatch
resource "aws_ses_event_destination" "cloudwatch" {
  count                  = var.create_configuration_set && var.enable_cloudwatch_destination ? 1 : 0
  name                   = "cloudwatch-destination"
  configuration_set_name = aws_ses_configuration_set.main[0].name
  enabled                = true
  matching_types         = var.cloudwatch_matching_types

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "MessageTag"
    value_source   = "messageTag"
  }
}

# SES Event Destination - SNS
resource "aws_ses_event_destination" "sns" {
  count                  = var.create_configuration_set && var.enable_sns_destination && var.sns_topic_arn != null ? 1 : 0
  name                   = "sns-destination"
  configuration_set_name = aws_ses_configuration_set.main[0].name
  enabled                = true
  matching_types         = ["bounce", "complaint"]

  sns_destination {
    topic_arn = var.sns_topic_arn
  }
}

# SES Event Destination - Kinesis Firehose
resource "aws_ses_event_destination" "kinesis" {
  count                  = var.create_configuration_set && var.enable_kinesis_destination && var.kinesis_firehose_arn != null ? 1 : 0
  name                   = "kinesis-destination"
  configuration_set_name = aws_ses_configuration_set.main[0].name
  enabled                = true
  matching_types         = var.cloudwatch_matching_types

  kinesis_destination {
    stream_arn = var.kinesis_firehose_arn
    role_arn   = var.kinesis_iam_role_arn
  }
}

# SES Identity Policies
resource "aws_ses_identity_policy" "sending_policy" {
  for_each = var.create_sending_policy && length(var.allowed_senders) > 0 ? toset(var.email_addresses) : toset([])
  
  identity = each.value
  name     = "${var.service_name}-sending-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_senders
        }
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/${each.value}"
      }
    ]
  })

  depends_on = [aws_ses_email_identity.email_addresses]
}

# Custom Identity Policies
resource "aws_ses_identity_policy" "custom_policies" {
  for_each = var.custom_identity_policies
  
  identity = var.email_addresses[0]  # Apply to first email address
  name     = each.value.name
  policy   = each.value.policy

  depends_on = [aws_ses_email_identity.email_addresses]
}

# SES Email Templates
resource "aws_ses_template" "email_templates" {
  for_each = var.email_templates
  
  name         = each.key
  subject      = each.value.subject_part
  text         = each.value.text_part
  html         = each.value.html_part
}

# SES Account Level Suppression
resource "aws_sesv2_account_suppression_attributes" "suppression" {
  count = var.enable_account_level_suppression ? 1 : 0
  
  suppressed_reasons = var.suppressed_reasons
}

# SES Dedicated IP Pool (optional)
resource "aws_sesv2_dedicated_ip_pool" "main" {
  count = var.create_dedicated_ip_pool ? 1 : 0
  
  pool_name    = var.dedicated_ip_pool_name != null ? var.dedicated_ip_pool_name : "${var.service_name}-ip-pool"
  scaling_mode = "STANDARD"

  tags = merge(
    local.mandatory_tags,
    {
      Name = var.dedicated_ip_pool_name != null ? var.dedicated_ip_pool_name : "${var.service_name}-ip-pool"
    }
  )
}

# SES Contact List (for SESv2)
resource "aws_sesv2_contact_list" "main" {
  count = var.create_contact_list ? 1 : 0
  
  contact_list_name = var.contact_list_name != null ? var.contact_list_name : "${var.service_name}-contacts"
  description       = var.contact_list_description

  tags = merge(
    local.mandatory_tags,
    {
      Name = var.contact_list_name != null ? var.contact_list_name : "${var.service_name}-contacts"
    }
  )
}

# CloudWatch Alarms for SES Monitoring
resource "aws_cloudwatch_metric_alarm" "sending_quota" {
  count = var.create_sending_quota_alarm ? 1 : 0

  alarm_name          = "${var.service_name}-sending-quota"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Send"
  namespace           = "AWS/SES"
  period              = "86400"  # 24 hours
  statistic           = "Sum"
  threshold           = var.sending_quota_threshold
  alarm_description   = "This metric monitors SES sending quota usage for ${var.service_name}"
  alarm_actions       = var.alarm_actions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-sending-quota-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "bounce_rate" {
  count = var.create_bounce_rate_alarm ? 1 : 0

  alarm_name          = "${var.service_name}-bounce-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Bounce"
  namespace           = "AWS/SES"
  period              = "300"
  statistic           = "Average"
  threshold           = var.bounce_rate_threshold
  alarm_description   = "This metric monitors SES bounce rate for ${var.service_name}"
  alarm_actions       = var.alarm_actions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-bounce-rate-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "complaint_rate" {
  count = var.create_complaint_rate_alarm ? 1 : 0

  alarm_name          = "${var.service_name}-complaint-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Complaint"
  namespace           = "AWS/SES"
  period              = "300"
  statistic           = "Average"
  threshold           = var.complaint_rate_threshold
  alarm_description   = "This metric monitors SES complaint rate for ${var.service_name}"
  alarm_actions       = var.alarm_actions

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-complaint-rate-alarm"
    }
  )
}

# IAM Role for SES sending (optional)
resource "aws_iam_role" "ses_sending_role" {
  count = var.create_sending_policy && length(var.allowed_senders) == 0 ? 1 : 0
  
  name        = "${var.service_name}-ses-sending-role"
  description = "IAM role for sending emails via SES for ${var.service_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-ses-sending-role"
    }
  )
}

# IAM Policy for SES sending
resource "aws_iam_role_policy" "ses_sending_policy" {
  count = var.create_sending_policy && length(var.allowed_senders) == 0 ? 1 : 0
  
  name = "${var.service_name}-ses-sending-policy"
  role = aws_iam_role.ses_sending_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail",
          "ses:SendTemplatedEmail",
          "ses:SendBulkTemplatedEmail"
        ]
        Resource = [
          for email in var.email_addresses :
          "arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/${email}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ses:GetSendQuota",
          "ses:GetSendStatistics",
          "ses:GetIdentityVerificationAttributes",
          "ses:GetIdentityDkimAttributes"
        ]
        Resource = "*"
      }
    ]
  })
}

# SES Receipt Rule Set (optional)
resource "aws_ses_receipt_rule_set" "main" {
  count         = var.domain_name != null ? 1 : 0
  rule_set_name = "${var.service_name}-receipt-rules"
}

# SES Receipt Rule (optional)
resource "aws_ses_receipt_rule" "main" {
  count         = var.domain_name != null ? 1 : 0
  name          = "${var.service_name}-receipt-rule"
  rule_set_name = aws_ses_receipt_rule_set.main[0].rule_set_name
  recipients    = [var.domain_name]
  enabled       = true
  scan_enabled  = true

  # Store emails in S3 (optional)
  s3_action {
    bucket_name = "${var.service_name}-email-storage"
    position    = 1
  }
}
