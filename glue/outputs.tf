
output "database_name" {
  description = "Name of the Glue catalog database"
  value       = aws_glue_catalog_database.this.name
}

output "database_arn" {
  description = "ARN of the Glue catalog database"
  value       = aws_glue_catalog_database.this.arn
}

output "glue_role_arn" {
  description = "ARN of the Glue IAM role"
  value       = aws_iam_role.glue_role.arn
}

output "glue_role_name" {
  description = "Name of the Glue IAM role"
  value       = aws_iam_role.glue_role.name
}

output "job_names" {
  description = "Names of the Glue jobs"
  value       = [for job in aws_glue_job.jobs : job.name]
}

output "job_arns" {
  description = "ARNs of the Glue jobs"
  value       = [for job in aws_glue_job.jobs : job.arn]
}

output "crawler_names" {
  description = "Names of the Glue crawlers"
  value       = [for crawler in aws_glue_crawler.crawlers : crawler.name]
}

output "crawler_arns" {
  description = "ARNs of the Glue crawlers"
  value       = [for crawler in aws_glue_crawler.crawlers : crawler.arn]
}

output "connection_names" {
  description = "Names of the Glue connections"
  value       = [for connection in aws_glue_connection.connections : connection.name]
}

output "connection_arns" {
  description = "ARNs of the Glue connections"
  value       = [for connection in aws_glue_connection.connections : connection.arn]
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for Glue jobs"
  value       = aws_cloudwatch_log_group.glue_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for Glue jobs"
  value       = aws_cloudwatch_log_group.glue_logs.arn
}

output "glue_version" {
  description = "Version of AWS Glue being used"
  value       = var.glue_version
}

output "worker_type" {
  description = "Worker type for Glue jobs"
  value       = var.worker_type
}

output "number_of_workers" {
  description = "Number of workers for Glue jobs"
  value       = var.number_of_workers
}
