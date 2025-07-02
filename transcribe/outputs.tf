
output "transcribe_role_arn" {
  description = "ARN of the Transcribe service IAM role"
  value       = aws_iam_role.transcribe_role.arn
}

output "transcribe_role_name" {
  description = "Name of the Transcribe service IAM role"
  value       = aws_iam_role.transcribe_role.name
}

output "lambda_trigger_role_arn" {
  description = "ARN of the Lambda trigger IAM role (if created)"
  value       = var.create_lambda_trigger_role ? aws_iam_role.transcribe_lambda_role[0].arn : null
}

output "lambda_trigger_role_name" {
  description = "Name of the Lambda trigger IAM role (if created)"
  value       = var.create_lambda_trigger_role ? aws_iam_role.transcribe_lambda_role[0].name : null
}

output "log_group_name" {
  description = "CloudWatch log group name for Transcribe"
  value       = aws_cloudwatch_log_group.transcribe_logs.name
}

output "log_group_arn" {
  description = "CloudWatch log group ARN for Transcribe"
  value       = aws_cloudwatch_log_group.transcribe_logs.arn
}

output "custom_vocabulary_name" {
  description = "Name of the custom vocabulary (if created)"
  value       = var.create_custom_vocabulary ? aws_transcribe_vocabulary.custom_vocabulary[0].vocabulary_name : null
}

output "custom_vocabulary_id" {
  description = "ID of the custom vocabulary (if created)"
  value       = var.create_custom_vocabulary ? aws_transcribe_vocabulary.custom_vocabulary[0].id : null
}

output "language_model_name" {
  description = "Name of the custom language model (if created)"
  value       = var.create_language_model ? aws_transcribe_language_model.custom_language_model[0].model_name : null
}

output "language_model_arn" {
  description = "ARN of the custom language model (if created)"
  value       = var.create_language_model ? aws_transcribe_language_model.custom_language_model[0].arn : null
}

# Configuration outputs for use in applications
output "transcribe_config" {
  description = "Configuration object for Transcribe service integration"
  value = {
    service_role_arn           = aws_iam_role.transcribe_role.arn
    log_group_name            = aws_cloudwatch_log_group.transcribe_logs.name
    language_code             = var.language_code
    media_format              = var.media_format
    media_sample_rate_hertz   = var.media_sample_rate_hertz
    channel_identification    = var.channel_identification
    show_speaker_labels       = var.show_speaker_labels
    max_speaker_labels        = var.max_speaker_labels
    custom_vocabulary_name    = var.create_custom_vocabulary ? aws_transcribe_vocabulary.custom_vocabulary[0].vocabulary_name : null
    language_model_name       = var.create_language_model ? aws_transcribe_language_model.custom_language_model[0].model_name : null
    output_bucket_name        = var.output_bucket_name != null ? var.output_bucket_name : var.s3_bucket_name
    output_key_prefix         = var.output_key_prefix
  }
}

# S3 integration outputs
output "s3_integration" {
  description = "S3 integration configuration"
  value = {
    input_bucket_name         = var.s3_bucket_name
    input_bucket_arn          = var.s3_bucket_arn
    output_bucket_name        = var.output_bucket_name != null ? var.output_bucket_name : var.s3_bucket_name
    notification_enabled      = var.enable_s3_notifications
    notification_filter_prefix = var.s3_notification_filter_prefix
    notification_filter_suffix = var.s3_notification_filter_suffix
  }
}
