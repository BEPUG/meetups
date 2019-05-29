# Windows Compatibility demo (if you don't have Windows 10 1809)

Get-NetAdapter
Get-LocalUser

$Env:PSModulePath -split ';'

Get-Module
Get-Module -ListAvailable

Find-Module WindowsCompatibility -Repository PSGallery
# Install-Module WindowsCompatibility

Get-Command -Module WindowsCompatibility

Invoke-WinCommand { Get-NetAdapter}

# Get-Service winrm
# Start-Service winrm
# Enable-PSRemoting

Invoke-WinCommand { Get-LocalUser } | Select-Object name,enabled

Get-PSSession

#region Windows Compatibility Pack in PowerShell Core 6.1 on Windows 10 1809 and Server 2019

# Demo.ps1 on Windows 10 Preview build 17744 in Hyper-V VM

cd 'C:\demo-pscore'
psedit NEW_Microsoft.PowerShell.LocalAccounts.psd1
psedit NEW_NetAdapter.psd1

#endregion



# get the list of available modules
Get-WinModule

Import-WinModule NetAdapter

Get-Module

Get-NetAdapter
Invoke-WinCommand {Get-NetAdapter}

<#
Invoke-WinCommand allows you to invokes a one-time command in the compatibility session.
Add-WinFunction allows you to define new functions that operate implicitly in the compatibility session.
Compare-WinModule lets you compare what you have against what’s available.
Copy-WinModule will let you copy Window PowerShell modules that are known to work in PowerShell 6 to the
 PowerShell 6 command path.
Initialize-WinSession gives you more control on where and how the compatibility session is created.
 For example. it will allow you to place the compatibility session on another machine.
#>

# go to LON-CL1
# Initialize-WinSession -ComputerName LON-DC1
# Import-WinModule activedirectory
#
# or
#
# Import-WinModule activedirectory -ComputerName LON-DC1
