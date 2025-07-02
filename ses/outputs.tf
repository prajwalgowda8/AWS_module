
output "domain_identity_arn" {
  description = "ARN of the SES domain identity"
  value       = aws_ses_domain_identity.this.arn
}

output "domain_identity_verification_token" {
  description = "Verification token for the SES domain identity"
  value       = aws_ses_domain_identity.this.verification_token
}

output "dkim_tokens" {
  description = "DKIM tokens for the domain"
  value       = aws_ses_domain_dkim.this.dkim_tokens
}

output "configuration_set_name" {
  description = "Name of the SES configuration set"
  value       = var.create_configuration_set ? aws_ses_configuration_set.this[0].name : null
}

output "configuration_set_arn" {
  description = "ARN of the SES configuration set"
  value       = var.create_configuration_set ? aws_ses_configuration_set.this[0].arn : null
}

output "mail_from_domain" {
  description = "Mail from domain"
  value       = var.mail_from_domain != null ? aws_ses_domain_mail_from.this[0].mail_from_domain : null
}
