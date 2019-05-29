<#
VSCode > split terminal: switch to PowerShell 6, split terminal, bash starts, pwsh and voila!
One terminal 6.1 on Windows, the other 6.1 on Linux
#>

#region Use automatic and enviroment variables

# $Is... variables
$script:AzureRM_Profile = if($IsCoreCLR){'AzureRM.Profile.NetCore'}else{'AzureRM.Profile'}

$script:AzureRM_Resources = if($IsCoreCLR){'AzureRM.Resources.Netcore'}else{'AzureRM.Resources'}

$Private:Mode = if( Get-Variable IsMacOS -ErrorAction SilentlyContinue ) { 'Exclusive' } else { 'Shared' }
#endregion

#region Use casing in Linux
# On Windows: $env:Path and $env:PSModulePath
# On Linux:   $env:PATH and $env:PSModulePath
#endregion

#region Use .NET Core types' properties and methods instead of hardcoded values
[IO.Path]::PathSeparator

[System.IO.Path]::Combine('Azure:', '*', 'ResourceGroups', '*')

if([System.IO.Path]::DirectorySeparatorChar -eq '\'){'\\'}else{'/'}



# Automatically pick resource group when inside resourcegroups of Azure drive

$Global:PSDefaultParameterValues['*-AzureRM*:ResourceGroupName'] = {if($pwd -like $script:pathPattern){($pwd -split $script:pathSeparator)[3]}}

[IO.Path] | Get-Member -Static

[IO.Path]::AltDirectorySeparatorChar
[IO.Path]::DirectorySeparatorChar
[IO.Path]::PathSeparator
[IO.Path]::VolumeSeparatorChar

<#
PS> [IO.Path]::
AltDirectorySeparatorChar    GetExtension                 GetTempFileName
DirectorySeparatorChar       GetFileName                  GetTempPath
InvalidPathChars             GetFileNameWithoutExtension  HasExtension
PathSeparator                GetFullPath                  IsPathFullyQualified
VolumeSeparatorChar          GetInvalidFileNameChars      IsPathRooted
ChangeExtension              GetInvalidPathChars          Join
Combine                      GetPathRoot                  ReferenceEquals
Equals                       GetRandomFileName            TryJoin
GetDirectoryName             GetRelativePath
PS /home> [IO.Path]::GetTempPath()
#>

<#
PS /home> [IO.Path]::Combine("$HOME","scripts")
/home/aleksandar/scripts

PS C:\> [IO.Path]::Combine("$HOME","scripts")
C:\Users\aleksandar\scripts
#>

Join-Path $HOME "scripts"

<#
PS> [environment]::
CommandLine                 StackTrace                  ExpandEnvironmentVariables
CurrentDirectory            SystemDirectory             FailFast
CurrentManagedThreadId      SystemPageSize              GetCommandLineArgs
ExitCode                    TickCount                   GetEnvironmentVariable
HasShutdownStarted          UserDomainName              GetEnvironmentVariables
Is64BitOperatingSystem      UserInteractive             GetFolderPath
Is64BitProcess              UserName                    GetLogicalDrives
MachineName                 Version                     ReferenceEquals
NewLine                     WorkingSet                  SetEnvironmentVariable
OSVersion                   Equals
ProcessorCount              Exit
#>

<#
PS> [System.Management.Automation.Platform]::
IsCoreCLR                      IsNanoServer                   ReferenceEquals
IsIoT                          IsWindows                      SelectProductNameForDirectory
IsLinux                        IsWindowsDesktop
IsMacOS                        Equals
#>