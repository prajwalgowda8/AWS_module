
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where jump servers will be created"
  type        = string
}

# Linux Jump Server Configuration
variable "create_linux_jump_server" {
  description = "Create Linux jump server"
  type        = bool
  default     = true
}

variable "linux_instance_type" {
  description = "Instance type for Linux jump server"
  type        = string
  default     = "t2.medium"
}

variable "linux_subnet_id" {
  description = "Subnet ID for Linux jump server"
  type        = string
}

variable "linux_ami_id" {
  description = "AMI ID for Linux jump server (if not specified, latest Amazon Linux 2 will be used)"
  type        = string
  default     = null
}

variable "linux_root_volume_size" {
  description = "Root volume size for Linux jump server in GB"
  type        = number
  default     = 20
}

# Windows Jump Server Configuration
variable "create_windows_jump_server" {
  description = "Create Windows jump server"
  type        = bool
  default     = true
}

variable "windows_instance_type" {
  description = "Instance type for Windows jump server"
  type        = string
  default     = "t3.large"
}

variable "windows_subnet_id" {
  description = "Subnet ID for Windows jump server"
  type        = string
}

variable "windows_ami_id" {
  description = "AMI ID for Windows jump server (if not specified, latest Windows Server 2022 will be used)"
  type        = string
  default     = null
}

variable "windows_root_volume_size" {
  description = "Root volume size for Windows jump server in GB"
  type        = number
  default     = 50
}

# Key Pair Configuration
variable "create_key_pair" {
  description = "Create a new key pair for jump servers"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key content for SSH access (required if create_key_pair is true)"
  type        = string
  default     = null
}

variable "existing_key_pair_name" {
  description = "Name of existing key pair to use"
  type        = string
  default     = null
}

# Network Configuration
variable "associate_public_ip" {
  description = "Associate public IP address with jump servers"
  type        = bool
  default     = true
}

variable "create_elastic_ip" {
  description = "Create Elastic IP for jump servers"
  type        = bool
  default     = false
}

# Security Configuration
variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to Linux jump server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_rdp_cidr_blocks" {
  description = "CIDR blocks allowed to RDP to Windows jump server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "additional_linux_ports" {
  description = "Additional ports to open for Linux jump server"
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "additional_windows_ports" {
  description = "Additional ports to open for Windows jump server"
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

# Storage Configuration
variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "Root volume type must be one of: gp2, gp3, io1, io2."
  }
}

variable "encrypt_volumes" {
  description = "Encrypt EBS volumes"
  type        = bool
  default     = true
}

# IAM Configuration
variable "additional_iam_policies" {
  description = "Additional IAM policy ARNs to attach to jump server role"
  type        = list(string)
  default     = []
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all jump server resources"
  type        = map(string)
  validation {
    condition = alltrue([
      contains(keys(var.mandatory_tags), "Environment"),
      contains(keys(var.mandatory_tags), "Project"),
      contains(keys(var.mandatory_tags), "Owner")
    ])
    error_message = "Mandatory tags must include Environment, Project, and Owner."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to all jump server resources"
  type        = map(string)
  default     = {}
}
