
<powershell>
# Set hostname
Rename-Computer -NewName "${hostname}" -Force

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install essential packages
choco install -y `
    awscli `
    git `
    notepadplusplus `
    7zip `
    googlechrome `
    putty `
    winscp `
    vscode

# Install kubectl
curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
Move-Item .\kubectl.exe C:\Windows\System32\

# Install Helm
choco install -y kubernetes-helm

# Install Session Manager plugin
$url = "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe"
$output = "$env:TEMP\SessionManagerPluginSetup.exe"
Invoke-WebRequest -Uri $url -OutFile $output
Start-Process -FilePath $output -ArgumentList "/S" -Wait

# Install CloudWatch agent
$url = "https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi"
$output = "$env:TEMP\amazon-cloudwatch-agent.msi"
Invoke-WebRequest -Uri $url -OutFile $output
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $output /quiet" -Wait

# Configure Windows features
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

# Create desktop shortcuts
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:PUBLIC\Desktop\AWS CLI.lnk")
$Shortcut.TargetPath = "cmd.exe"
$Shortcut.Arguments = "/k aws --version"
$Shortcut.Save()

# Set up welcome message
$welcomeMessage = @"
Welcome to Study Companion Windows Jump Server
==============================================

Available tools:
- AWS CLI
- kubectl  
- Docker Desktop (install manually if needed)
- Helm
- Session Manager
- Visual Studio Code
- Git

Use 'aws configure' in Command Prompt to set up your AWS credentials.
"@

Set-Content -Path "$env:PUBLIC\Desktop\Welcome.txt" -Value $welcomeMessage

# Restart required
Restart-Computer -Force
</powershell>
