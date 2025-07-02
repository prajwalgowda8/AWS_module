
<powershell>
# Set hostname
Rename-Computer -NewName "${hostname}" -Force

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install essential tools via Chocolatey
choco install -y `
    awscli `
    kubernetes-cli `
    terraform `
    git `
    notepadplusplus `
    7zip `
    putty `
    winscp `
    googlechrome `
    firefox `
    vscode

# Install AWS Tools for PowerShell
Install-Module -Name AWS.Tools.Installer -Force -AllowClobber
Install-AWSToolsModule AWS.Tools.EC2,AWS.Tools.S3,AWS.Tools.EKS,AWS.Tools.RDS -Force

# Install Session Manager Plugin
$sessionManagerUrl = "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe"
$sessionManagerPath = "$env:TEMP\SessionManagerPluginSetup.exe"
Invoke-WebRequest -Uri $sessionManagerUrl -OutFile $sessionManagerPath
Start-Process -FilePath $sessionManagerPath -ArgumentList "/S" -Wait
Remove-Item $sessionManagerPath

# Install CloudWatch Agent
$cloudWatchUrl = "https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi"
$cloudWatchPath = "$env:TEMP\amazon-cloudwatch-agent.msi"
Invoke-WebRequest -Uri $cloudWatchUrl -OutFile $cloudWatchPath
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $cloudWatchPath /quiet" -Wait
Remove-Item $cloudWatchPath

# Configure PowerShell profile with useful aliases
$profilePath = $PROFILE.AllUsersAllHosts
$profileDir = Split-Path $profilePath -Parent
if (!(Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}

@"
# AWS Jump Server PowerShell Profile
Write-Host "======================================" -ForegroundColor Green
Write-Host "    AWS Jump Server (Windows)" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host "Hostname: ${hostname}" -ForegroundColor Yellow
Write-Host "Tools installed:" -ForegroundColor Yellow
Write-Host "- AWS CLI & PowerShell Tools" -ForegroundColor White
Write-Host "- kubectl" -ForegroundColor White
Write-Host "- Terraform" -ForegroundColor White
Write-Host "- Git" -ForegroundColor White
Write-Host "- Visual Studio Code" -ForegroundColor White
Write-Host "- Session Manager Plugin" -ForegroundColor White
Write-Host "- CloudWatch Agent" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "Use 'aws configure' to set up AWS credentials" -ForegroundColor Cyan
Write-Host "Use 'kubectl' to manage Kubernetes clusters" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Green

# Useful aliases
Set-Alias -Name k -Value kubectl
Set-Alias -Name tf -Value terraform

# AWS shortcuts
function Get-AWSWhoAmI { aws sts get-caller-identity }
function Get-AWSRegion { aws configure get region }

# Kubernetes shortcuts
function Get-KubePods { kubectl get pods }
function Get-KubeServices { kubectl get services }
function Get-KubeNodes { kubectl get nodes }

Set-Alias -Name awswhoami -Value Get-AWSWhoAmI
Set-Alias -Name awsregion -Value Get-AWSRegion
Set-Alias -Name kgp -Value Get-KubePods
Set-Alias -Name kgs -Value Get-KubeServices
Set-Alias -Name kgn -Value Get-KubeNodes
"@ | Out-File -FilePath $profilePath -Encoding UTF8

# Enable RDP (should already be enabled, but ensuring it's configured)
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Configure Windows Firewall for additional management ports if needed
# New-NetFirewallRule -DisplayName "Allow WinRM HTTPS" -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

# Start and configure services
Start-Service -Name "AmazonSSMAgent" -ErrorAction SilentlyContinue
Set-Service -Name "AmazonSSMAgent" -StartupType Automatic -ErrorAction SilentlyContinue

Write-Host "Windows Jump Server setup completed successfully!" -ForegroundColor Green

# Schedule a restart to apply hostname change
shutdown /r /t 60 /c "Restarting to apply hostname change. The system will restart in 1 minute."
</powershell>
