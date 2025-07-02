
# Linux Jump Server Outputs
output "linux_jump_server_id" {
  description = "ID of the Linux jump server"
  value       = var.create_linux_jump_server ? aws_instance.linux_jump_server[0].id : null
}

output "linux_jump_server_private_ip" {
  description = "Private IP address of the Linux jump server"
  value       = var.create_linux_jump_server ? aws_instance.linux_jump_server[0].private_ip : null
}

output "linux_jump_server_public_ip" {
  description = "Public IP address of the Linux jump server"
  value       = var.create_linux_jump_server ? aws_instance.linux_jump_server[0].public_ip : null
}

output "linux_jump_server_elastic_ip" {
  description = "Elastic IP address of the Linux jump server"
  value       = var.create_linux_jump_server && var.create_elastic_ip ? aws_eip.linux_jump_server[0].public_ip : null
}

output "linux_security_group_id" {
  description = "Security group ID for the Linux jump server"
  value       = var.create_linux_jump_server ? aws_security_group.linux_jump_server[0].id : null
}

# Windows Jump Server Outputs
output "windows_jump_server_id" {
  description = "ID of the Windows jump server"
  value       = var.create_windows_jump_server ? aws_instance.windows_jump_server[0].id : null
}

output "windows_jump_server_private_ip" {
  description = "Private IP address of the Windows jump server"
  value       = var.create_windows_jump_server ? aws_instance.windows_jump_server[0].private_ip : null
}

output "windows_jump_server_public_ip" {
  description = "Public IP address of the Windows jump server"
  value       = var.create_windows_jump_server ? aws_instance.windows_jump_server[0].public_ip : null
}

output "windows_jump_server_elastic_ip" {
  description = "Elastic IP address of the Windows jump server"
  value       = var.create_windows_jump_server && var.create_elastic_ip ? aws_eip.windows_jump_server[0].public_ip : null
}

output "windows_security_group_id" {
  description = "Security group ID for the Windows jump server"
  value       = var.create_windows_jump_server ? aws_security_group.windows_jump_server[0].id : null
}

# Common Outputs
output "key_pair_name" {
  description = "Name of the key pair used for jump servers"
  value       = var.create_key_pair ? aws_key_pair.jump_server[0].key_name : var.existing_key_pair_name
}

output "iam_role_arn" {
  description = "ARN of the IAM role for jump servers"
  value       = aws_iam_role.jump_server_role.arn
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for jump servers"
  value       = aws_iam_instance_profile.jump_server_profile.name
}

# Connection Information
output "connection_info" {
  description = "Connection information for jump servers"
  value = {
    linux = var.create_linux_jump_server ? {
      ssh_command = "ssh -i ${var.create_key_pair ? aws_key_pair.jump_server[0].key_name : var.existing_key_pair_name}.pem ec2-user@${var.create_elastic_ip ? aws_eip.linux_jump_server[0].public_ip : aws_instance.linux_jump_server[0].public_ip}"
      private_ip  = aws_instance.linux_jump_server[0].private_ip
      public_ip   = var.create_elastic_ip ? aws_eip.linux_jump_server[0].public_ip : aws_instance.linux_jump_server[0].public_ip
    } : null
    
    windows = var.create_windows_jump_server ? {
      rdp_address = var.create_elastic_ip ? aws_eip.windows_jump_server[0].public_ip : aws_instance.windows_jump_server[0].public_ip
      private_ip  = aws_instance.windows_jump_server[0].private_ip
      public_ip   = var.create_elastic_ip ? aws_eip.windows_jump_server[0].public_ip : aws_instance.windows_jump_server[0].public_ip
    } : null
  }
}
