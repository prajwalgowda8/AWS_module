
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
    tree \
    nc \
    telnet \
    tcpdump \
    awscli

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install kubectl
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.28.3/2023-11-14/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_1.6.6_linux_amd64.zip

# Install Session Manager plugin
yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

# Configure CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create a welcome message
cat > /etc/motd << 'EOF'
=====================================
    AWS Jump Server (Linux)
=====================================
Hostname: ${hostname}
Tools installed:
- AWS CLI
- kubectl
- eksctl
- Docker
- Terraform
- Session Manager Plugin
- CloudWatch Agent

Use 'aws configure' to set up AWS credentials
Use 'kubectl' to manage Kubernetes clusters
Use 'docker' to manage containers

=====================================
EOF

# Configure bash aliases for ec2-user
cat >> /home/ec2-user/.bashrc << 'EOF'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias k='kubectl'
alias tf='terraform'

# AWS shortcuts
alias awswhoami='aws sts get-caller-identity'
alias awsregion='aws configure get region'

# Kubernetes shortcuts
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'

EOF

# Set proper ownership
chown ec2-user:ec2-user /home/ec2-user/.bashrc

# Start and enable SSM agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent

echo "Jump server setup completed successfully!"
