
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair for SSH/RDP access
resource "aws_key_pair" "jump_server" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = "${var.name_prefix}-jump-server-key"
  public_key = var.public_key

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-jump-server-key"
    }
  )
}

# Security Group for Linux Jump Server
resource "aws_security_group" "linux_jump_server" {
  count       = var.create_linux_jump_server ? 1 : 0
  name_prefix = "${var.name_prefix}-linux-jump-sg"
  vpc_id      = var.vpc_id
  description = "Security group for Linux jump server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
    description = "SSH access"
  }

  dynamic "ingress" {
    for_each = var.additional_linux_ports
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-linux-jump-sg"
    }
  )
}

# Security Group for Windows Jump Server
resource "aws_security_group" "windows_jump_server" {
  count       = var.create_windows_jump_server ? 1 : 0
  name_prefix = "${var.name_prefix}-windows-jump-sg"
  vpc_id      = var.vpc_id
  description = "Security group for Windows jump server"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.allowed_rdp_cidr_blocks
    description = "RDP access"
  }

  dynamic "ingress" {
    for_each = var.additional_windows_ports
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-windows-jump-sg"
    }
  )
}

# IAM Role for Jump Servers
resource "aws_iam_role" "jump_server_role" {
  name = "${var.name_prefix}-jump-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-jump-server-role"
    }
  )
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "jump_server_profile" {
  name = "${var.name_prefix}-jump-server-profile"
  role = aws_iam_role.jump_server_role.name

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-jump-server-profile"
    }
  )
}

# Attach SSM policy for session manager access
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.jump_server_role.name
}

# Attach CloudWatch agent policy
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.jump_server_role.name
}

# Attach additional policies
resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = length(var.additional_iam_policies)
  policy_arn = var.additional_iam_policies[count.index]
  role       = aws_iam_role.jump_server_role.name
}

# Linux Jump Server
resource "aws_instance" "linux_jump_server" {
  count                  = var.create_linux_jump_server ? 1 : 0
  ami                    = var.linux_ami_id != null ? var.linux_ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.linux_instance_type
  key_name              = var.create_key_pair ? aws_key_pair.jump_server[0].key_name : var.existing_key_pair_name
  vpc_security_group_ids = [aws_security_group.linux_jump_server[0].id]
  subnet_id             = var.linux_subnet_id
  iam_instance_profile  = aws_iam_instance_profile.jump_server_profile.name

  associate_public_ip_address = var.associate_public_ip

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.linux_root_volume_size
    encrypted             = var.encrypt_volumes
    delete_on_termination = true

    tags = merge(
      var.mandatory_tags,
      var.additional_tags,
      {
        Name = "${var.name_prefix}-linux-jump-root-volume"
      }
    )
  }

  user_data = base64encode(templatefile("${path.module}/user_data/linux_user_data.sh", {
    hostname = "${var.name_prefix}-linux-jump"
  }))

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-linux-jump-server"
      Type = "JumpServer"
      OS   = "Linux"
    }
  )

  volume_tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-linux-jump-server"
    }
  )
}

# Windows Jump Server
resource "aws_instance" "windows_jump_server" {
  count                  = var.create_windows_jump_server ? 1 : 0
  ami                    = var.windows_ami_id != null ? var.windows_ami_id : data.aws_ami.windows.id
  instance_type          = var.windows_instance_type
  key_name              = var.create_key_pair ? aws_key_pair.jump_server[0].key_name : var.existing_key_pair_name
  vpc_security_group_ids = [aws_security_group.windows_jump_server[0].id]
  subnet_id             = var.windows_subnet_id
  iam_instance_profile  = aws_iam_instance_profile.jump_server_profile.name

  associate_public_ip_address = var.associate_public_ip

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.windows_root_volume_size
    encrypted             = var.encrypt_volumes
    delete_on_termination = true

    tags = merge(
      var.mandatory_tags,
      var.additional_tags,
      {
        Name = "${var.name_prefix}-windows-jump-root-volume"
      }
    )
  }

  user_data = base64encode(templatefile("${path.module}/user_data/windows_user_data.ps1", {
    hostname = "${var.name_prefix}-windows-jump"
  }))

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-windows-jump-server"
      Type = "JumpServer"
      OS   = "Windows"
    }
  )

  volume_tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-windows-jump-server"
    }
  )
}

# Elastic IPs (optional)
resource "aws_eip" "linux_jump_server" {
  count    = var.create_linux_jump_server && var.create_elastic_ip ? 1 : 0
  instance = aws_instance.linux_jump_server[0].id
  domain   = "vpc"

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-linux-jump-eip"
    }
  )
}

resource "aws_eip" "windows_jump_server" {
  count    = var.create_windows_jump_server && var.create_elastic_ip ? 1 : 0
  instance = aws_instance.windows_jump_server[0].id
  domain   = "vpc"

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.name_prefix}-windows-jump-eip"
    }
  )
}
