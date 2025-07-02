
output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "ARN to be used for invoking Lambda Function from API Gateway"
  value       = aws_lambda_function.this.invoke_arn
}

output "qualified_arn" {
  description = "ARN identifying your Lambda Function Version"
  value       = aws_lambda_function.this.qualified_arn
}

output "version" {
  description = "Latest published version of your Lambda Function"
  value       = aws_lambda_function.this.version
}

output "source_code_size" {
  description = "Size in bytes of the function .zip file"
  value       = aws_lambda_function.this.source_code_size
}

output "role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  value       = aws_iam_role.lambda_role.arn
}

output "role_name" {
  description = "Name of the IAM role for the Lambda function"
  value       = aws_iam_role.lambda_role.name
}

output "security_group_id" {
  description = "Security group ID for the Lambda function (if VPC is configured)"
  value       = length(aws_security_group.lambda_sg) > 0 ? aws_security_group.lambda_sg[0].id : null
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}
