
output "trail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.this.arn
}

output "trail_name" {
  description = "Name of the CloudTrail"
  value       = aws_cloudtrail.this.name
}

output "home_region" {
  description = "Region in which the trail was created"
  value       = aws_cloudtrail.this.home_region
}

output "cloudwatch_role_arn" {
  description = "ARN of the CloudWatch IAM role (if created)"
  value       = length(aws_iam_role.cloudtrail_cloudwatch_role) > 0 ? aws_iam_role.cloudtrail_cloudwatch_role[0].arn : null
}
