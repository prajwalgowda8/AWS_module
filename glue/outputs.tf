
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
