
# ... [Previous configuration remains the same until the SES module] ...

# SES for email service
module "ses" {
  source = "./modules/ses"

  domain_name = "studycompanion.com"
  mail_from_domain = "mail.studycompanion.com"
  
  create_configuration_set = true
  tls_policy = "Require"
  reputation_metrics_enabled = true
  
  enable_cloudwatch_destination = true
  cloudwatch_matching_types = ["send", "reject", "bounce", "complaint", "delivery"]
  
  log_retention_days = 14

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "Email"
    Service   = "SES"
  }
}
