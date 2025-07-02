
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "internet_gateway_id" {
  description = "ID of the existing Internet Gateway (if exists)"
  type        = string
  default     = null
}

variable "internet_gateway_name" {
  description = "Name of the Internet Gateway"
  type        = string
  default     = "imported-igw"
}

variable "cluster_name" {
  description = "Name of the EKS cluster for subnet tagging"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet configurations"
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
    route_table_index       = number
    tags                    = map(string)
  }))
  default = []
}

variable "private_subnets" {
  description = "List of private subnet configurations"
  type = list(object({
    name              = string
    cidr_block        = string
    availability_zone = string
    route_table_index = number
    tags              = map(string)
  }))
  default = []
}

variable "nat_gateways" {
  description = "List of NAT Gateway configurations"
  type = list(object({
    name          = string
    allocation_id = string
    subnet_index  = number
  }))
  default = []
}

variable "public_route_tables" {
  description = "List of public route table configurations"
  type = list(object({
    name = string
  }))
  default = []
}

variable "private_route_tables" {
  description = "List of private route table configurations"
  type = list(object({
    name = string
  }))
  default = []
}

variable "mandatory_tags" {
  description = "Mandatory tags that must be applied to all network resources"
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
  description = "Additional tags to apply to all network resources"
  type        = map(string)
  default     = {}
}
