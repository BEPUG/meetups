function Ctrl-C {
  <#
      .Synopsis
      Copy clipboard content to and from remote machines
      .DESCRIPTION
      .
      .EXAMPLE
      Example of how to use this cmdlet
      .EXAMPLE
      Another example of how to use this cmdlet
  #>
  begin
  { 
    function Connect-CCTarget
    {
      [CmdletBinding()]
      Param
      (
        # Param1 help description
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
        Position=0)]
        [string]
        $HostName,

        # Param2 help description
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
        Position=1)]
        $Credentials
      )

      Begin
      {
      }
      Process
      {
        Invoke-Command -VMName $HostName -Credential $Credentials -ScriptBlock `
        {
          $null = Register-PSSessionConfiguration -ThreadApartmentState STA -Name Ctrl-C -UseSharedProcess -ThreadOptions Default -Force
          #Get-PSSessionConfiguration -Name Ctrl-C
        }
    
        $global:target = New-PSSession -Name Ctrl-C -VMName $HostName -Credential $Credentials -ConfigurationName Ctrl-C
        $global:loopback = Invoke-Command -VMName $HostName -Credential $Credentials -ConfigurationName Ctrl-C -ScriptBlock `
        {
          New-PSSession -EnableNetworkAccess -Name Ctrl-C-Loopback -ConfigurationName Ctrl-C
        }
      }
      End
      {
      }
    }

    function Send-CCContent
    {
      Param
      (
        #[Parameter(ParameterSetName='File')]
        #[Parameter(ParameterSetName='Text')]
        [Parameter(
            Mandatory=$false,
        Position=0 )]
        [ValidateSet('Text','FileInfo')]
        [string]
        $ContentType = $global:ContentType,
    
        #[Parameter({if($ContentType -eq 'FileInfo') {$PsCmdlet.ParameterSetName='File'}})]
        #[Parameter({if($ContentType -eq 'Text') {$PsCmdlet.ParameterSetName='Text'}})]
        [Parameter(
            Mandatory=$false,
        Position=1 )]
        $Payload = $global:content,
    
        [Parameter(
            #ParameterSetName='File',
        Mandatory=$false )]
        [string]
        $DestinationPath = 'C:\Ctrl-c'
      )

      Begin
      {
        # For file content, we need to prepare a few things.
        # TO-DO: check if the destination path (full path) exists or Copy-VMFile will fail!
    
        if ($ContentType -eq 'FileInfo')
        {
          # We will need Guest Service Interface enabled on the VM as a prerequisite for Copy-VMFile.
          if ((Get-VMIntegrationService -VMName $HostName -Name 'Guest Service Interface').Enabled -eq $False)
          {
            Enable-VMIntegrationService -VMName $HostName -Name 'Guest Service Interface'
          }
      
          # Trim the trailing '\' from $DestinationPath, if any
          $DestinationPath = $DestinationPath.TrimEnd('\')
      
          # Need to figure out why $content is a List object ... Using [0] as a work-around.
          $content = $Content[0]
        }
    
      }
      Process
      {
        # If it's a file, copy it to the VM, then use Get-Item to retrieve the copied file on the remote host
        # and put it on the remote clipboard.
        if ($ContentType -eq 'FileInfo')
        {
          Copy-VMFile -Name $HostName -FileSource Host -SourcePath $payload.FullName -DestinationPath "$DestinationPath\$($Payload.Name)" -CreateFullPath
          Invoke-Command -Session $target {Get-Item "$Using:DestinationPath\$($Using:payload.Name)" | Set-Clipboard}
        }
    
        if ($ContentType -eq 'Text')
        {
          Invoke-Command -Session $target {Set-Clipboard $Using:payload}      
        }
      }
  
      End
      {
      }
    }

    function Read-CCClipboard
    {
      if ((Get-Clipboard) -ne $null)
      {
        $global:content = Get-Clipboard #-Format Text
        $global:contenttype = 'Text'
      }
      elseif ((Get-Clipboard -Format FileDropList) -ne $null)
      {
        $global:content = Get-Clipboard -Format FileDropList
        $global:contenttype = 'FileInfo'
      }
      else {Write 'Clipboard content is null or not supported.'}
    }
  }
  
  process
  { 
    #Connect-CCTarget -HostName (Read-Host 'Target host') -Credentials (Get-Credential)
    Connect-CCTarget -HostName 'Server1803' -Credentials $cred
    Read-CCClipboard
    Send-CCContent
  }
  
  end
  {
    #Get-PSSession | Remove-PSSession
  }

  <#
      Stuff for testing

      Get-Item -Path "C:\Users\merli\Downloads\7z1604-x64.exe" | Set-Clipboard -Append
      $clip = Get-Clipboard -Format FileDropList
      icm -VMName $RemoteHost -Credential $Cred -ConfigurationName Ctrl-C {Set-Clipboard $using:clip}

      add-type -AssemblyName presentationcore
      [windows.clipboard]::
  #>
}