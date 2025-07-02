
#!/bin/bash

# Update system
yum update -y

# Set hostname
hostnamectl set-hostname ${hostname}

# Install essential packages
yum install -y \
    htop \
    vim \
    git \
    curl \
    wget \
    unzip \
    jq \
    awscli

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install kubectl
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.28.3/2023-11-14/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Session Manager plugin
yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

# Configure CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create welcome message
cat > /etc/motd << 'EOF'
Welcome to Study Companion Linux Jump Server
============================================

Available tools:
- AWS CLI
- kubectl
- Docker
- Helm
- Session Manager

Use 'aws configure' to set up your AWS credentials.
EOF

# Restart services
systemctl restart sshd
