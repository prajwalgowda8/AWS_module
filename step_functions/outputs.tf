
output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.arn
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.name
}

output "state_machine_status" {
  description = "Current status of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.status
}

output "state_machine_creation_date" {
  description = "Creation date of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.creation_date
}

output "state_machine_type" {
  description = "Type of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.type
}

output "role_arn" {
  description = "ARN of the IAM role for the Step Functions state machine"
  value       = aws_iam_role.step_functions_role.arn
}

output "role_name" {
  description = "Name of the IAM role for the Step Functions state machine"
  value       = aws_iam_role.step_functions_role.name
}

output "role_unique_id" {
  description = "Unique ID of the IAM role for the Step Functions state machine"
  value       = aws_iam_role.step_functions_role.unique_id
}

output "log_group_name" {
  description = "CloudWatch log group name (if logging is enabled)"
  value       = var.enable_logging ? aws_cloudwatch_log_group.step_functions_logs[0].name : null
}

output "log_group_arn" {
  description = "CloudWatch log group ARN (if logging is enabled)"
  value       = var.enable_logging ? aws_cloudwatch_log_group.step_functions_logs[0].arn : null
}

output "logging_enabled" {
  description = "Whether CloudWatch logging is enabled"
  value       = var.enable_logging
}

output "tracing_enabled" {
  description = "Whether X-Ray tracing is enabled"
  value       = var.enable_tracing
}

output "encryption_enabled" {
  description = "Whether encryption is enabled"
  value       = var.enable_encryption
}

output "definition" {
  description = "Amazon States Language definition of the state machine"
  value       = var.definition
  sensitive   = true
}
