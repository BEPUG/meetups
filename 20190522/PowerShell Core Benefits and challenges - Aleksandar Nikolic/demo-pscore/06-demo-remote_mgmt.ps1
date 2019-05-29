Get-Command -Module PSCloudShellUtility

# needs 2 minutes to complete
Enable-AzVMPSRemoting -Name Win2016 -ResourceGroupName techorama-rg -OsType Windows -Protocol https

# needs a minute to complete
Enable-AzVMPSRemoting -Name Ubuntu1804 -ResourceGroupName techorama-rg -OsType Linux -Protocol ssh

$cred = Get-Credential demouser
Invoke-AzVMCommand -Name Win2016 -ResourceGroupName techorama-rg -ScriptBlock {Get-Process} -Credential $cred

Invoke-AzVMCommand -Name Ubuntu1804 -ResourceGroupName techorama-rg -ScriptBlock {Get-Process} -UserName mas -KeyFilePath ~/.ssh/id_rsa

Enter-AzVM -Name Ubuntu1804 -ResourceGroupName techorama-rg -UserName mas -KeyFilePath ~/.ssh/id_rsa