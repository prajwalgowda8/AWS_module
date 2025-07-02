
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# SES Domain Identity
resource "aws_ses_domain_identity" "this" {
  domain = var.domain_name
}

# SES Domain DKIM
resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

# SES Domain Mail From
resource "aws_ses_domain_mail_from" "this" {
  count            = var.mail_from_domain != null ? 1 : 0
  domain           = aws_ses_domain_identity.this.domain
  mail_from_domain = var.mail_from_domain
}

# SES Configuration Set
resource "aws_ses_configuration_set" "this" {
  count = var.create_configuration_set ? 1 : 0
  name  = "${replace(var.domain_name, ".", "-")}-config-set"

  delivery_options {
    tls_policy = var.tls_policy
  }

  reputation_metrics_enabled = var.reputation_metrics_enabled
}

# SES Event Destination
resource "aws_ses_event_destination" "cloudwatch" {
  count                  = var.create_configuration_set && var.enable_cloudwatch_destination ? 1 : 0
  name                   = "cloudwatch-destination"
  configuration_set_name = aws_ses_configuration_set.this[0].name
  enabled                = true
  matching_types         = var.cloudwatch_matching_types

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "MessageTag"
    value_source   = "messageTag"
  }
}

# CloudWatch Log Group for SES
resource "aws_cloudwatch_log_group" "ses_logs" {
  count             = var.enable_cloudwatch_destination ? 1 : 0
  name              = "/aws/ses/${var.domain_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.domain_name}-ses-logs"
    }
  )
}
