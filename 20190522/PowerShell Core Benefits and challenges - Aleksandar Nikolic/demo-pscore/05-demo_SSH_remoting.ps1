
# Open bash in Azure Cloud Shell

#region Create a Linux Azure VM
<#
az group create --name ps-rg --location eastus

az vm create \
  --resource-group ps-rg \
  --name myVM \
  --image UbuntuLTS \
  --admin-username demouser \
  --generate-ssh-keys

  # Ubuntu 16.04
#>
#endregion

#region Install PowerShell Core and configure SSH on Linux Azure VM
  ssh demouser@13.68.173.26

# Import the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Register the Microsoft Ubuntu repository
sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list

# Update the list of products
sudo apt-get update

# Install PowerShell
sudo apt-get install -y powershell

# Start PowerShell
pwsh

# now, configure sshd_config
# Edit the sshd_config file at location /etc/ssh

cd /etc/ssh
ls -a

sudo nano sshd_config
# Subsystem powershell /usr/bin/pwsh -sshs -NoLogo -NoProfile

sudo service sshd restart
#endregion

#region Steps to add the public key to Linux Azure VM
# Run the following commands on a client

# Create VM config object
$vmconfig = Get-AzureRmVM -ResourceGroupName ps-rg -Name myvm

# Ensure VM config is updated with SSH keys
$sshPublicKey = Get-Content "$HOME\.ssh\id_rsa.pub"
Add-AzureRmVMSshPublicKey -VM $vmConfig -KeyData $sshPublicKey -Path "/home/demouser/.ssh/authorized_keys"

Update-AzureRmVM -ResourceGroupName ps-rg -VM $vmConfig -Verbose
#endregion

# Connect with PowerShell Core on Windows
New-PSSession -HostName 13.68.173.16 -username demouser -KeyFilePath $HOME/.ssh/id_rsa -OutVariable session

# Connect with PowerShell Core on WSL
pwsh
New-PSSession -HostName 13.68.173.16 -username demouser -KeyFilePath $HOME/.ssh/id_rsa -OutVariable session

# Connect with PowerShell Core in Azure Cloud Shell
pwsh
New-PSSession -hostname 13.68.173.16 -username demouser -KeyFilePath $HOME/.ssh/id_rsa -OutVariable session


# icm $session {gps pwsh}

#region SSH-remoting: Windows to Linux

# Enable-AzVMPSRemoting -ResourceGroupName lab-rg -Name lon-ubuntu1 -OsType Linux -Protocol ssh -Verbose

<#
sudo wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
sshdconfigfile=/etc/ssh/sshd_config
sudo sed -re "s/^(\#)(PasswordAuthentication)([[:space:]]+)(.*)/\2\3\4/" -i.`date -I` "$sshdconfigfile"
sudo sed -re "s/^(PasswordAuthentication)([[:space:]]+)no/\1\2yes/" -i.`date -I` "$sshdconfigfile"
subsystem="Subsystem powershell /usr/bin/pwsh -sshs -NoLogo -NoProfile"
sudo grep -qF -- "$subsystem" "$sshdconfigfile" || sudo echo "$subsystem" | sudo tee --append "$sshdconfigfile"
sudo service sshd restart
#>

# https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH

Enter-PSSession -HostName 10.2.1.7 -UserName demouser

$s = New-PSSession -HostName 10.2.1.7 -UserName demouser
Invoke-Command $s {Get-Process} | Get-Member

#endregion