
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

output "role_arn" {
  description = "ARN of the IAM role for the Step Functions state machine"
  value       = aws_iam_role.step_functions_role.arn
}

output "role_name" {
  description = "Name of the IAM role for the Step Functions state machine"
  value       = aws_iam_role.step_functions_role.name
}

output "log_group_name" {
  description = "CloudWatch log group name (if logging is enabled)"
  value       = var.enable_logging ? aws_cloudwatch_log_group.step_functions_logs[0].name : null
}

output "log_group_arn" {
  description = "CloudWatch log group ARN (if logging is enabled)"
  value       = var.enable_logging ? aws_cloudwatch_log_group.step_functions_logs[0].arn : null
}
