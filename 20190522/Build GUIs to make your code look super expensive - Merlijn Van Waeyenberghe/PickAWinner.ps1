$path = "C:\git\BEPUG\meetups\20190522\Build GUIs to make your code look super expensive - Merlijn Van Waeyenberghe\Eventbrite.csv"
$csv = Import-Csv $path



#region XAML window definition
# Right-click XAML and choose WPF/Edit... to edit WPF Design
# in your favorite WPF editing tool
$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
   MinWidth="200"
   Width ="400"
   SizeToContent="Height"
   Title="WinnerPicker 5.3.1"
   Topmost="True" Icon="C:\git\BEPUG\meetups\20190522\Build GUIs to make your code look super expensive - Merlijn Van Waeyenberghe\clinking-beer-mugs.png">
   <Grid Margin="10,40,10,10">
      <Grid.ColumnDefinitions>
         <ColumnDefinition Width="Auto"/>
         <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>
      <Grid.RowDefinitions>
         <RowDefinition Height="Auto"/>
         <RowDefinition Height="Auto"/>
         <RowDefinition Height="Auto"/>
         <RowDefinition Height="*"/>
      </Grid.RowDefinitions>
        <TextBlock Grid.Column="0" Grid.Row="0" Grid.ColumnSpan="2" Margin="5" Text="Please select file"/>

        <TextBlock Grid.Column="0" Grid.Row="2" Margin="5" Text="Delimiter"/>
        <TextBox x:Name="TxtDelimiter" Grid.Column="1" Grid.Row="2" Margin="44,5,250.333,5"></TextBox>

      <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,10,0,0" Grid.Row="3" Grid.ColumnSpan="2">
            <Button x:Name="ButPickWinner" MinWidth="80" Height="22" Margin="5" Content="Pick a winner!"/>
            <Button Name="ButCancel" MinWidth="80" Height="22" Margin="5">Cancel</Button>
      </StackPanel>
        <Button x:Name="ButBrowse" Content="Browse..." Grid.Column="1" HorizontalAlignment="Left" Height="16" Margin="99,5,0,0" VerticalAlignment="Top" Width="150"/>
        <TextBox x:Name="TxtWinner" Grid.Column="1" HorizontalAlignment="Left" Height="22" Margin="10,10,0,0" Grid.Row="3" TextWrapping="Wrap" VerticalAlignment="Top" Width="109"/>
    </Grid>
</Window>
'@
#endregion

#region Code Behind
Function Get-FileName($initialDirectory)
{   
  [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
  Out-Null

  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.initialDirectory = $initialDirectory
  $OpenFileDialog.filter = “All files (*.*)| *.*”
  $OpenFileDialog.ShowDialog() | Out-Null
  $OpenFileDialog.filename
} #end function Get-FileName
function Convert-XAMLtoWindow
{
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $XAML
  )
  
  Add-Type -AssemblyName PresentationFramework
  
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  $result = [Windows.Markup.XAMLReader]::Load($reader)
  $reader.Close()
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  while ($reader.Read())
  {
      $name=$reader.GetAttribute('Name')
      if (!$name) { $name=$reader.GetAttribute('x:Name') }
      if($name)
      {$result | Add-Member NoteProperty -Name $name -Value $result.FindName($name) -Force}
  }
  $reader.Close()
  $result
}

function Show-WPFWindow
{
  param
  (
    [Parameter(Mandatory=$true)]
    [Windows.Window]
    $Window
  )
  
  $result = $null
  $null = $window.Dispatcher.InvokeAsync{
    $result = $window.ShowDialog()
    Set-Variable -Name result -Value $result -Scope 1
  }.Wait()
  $result
}
#endregion Code Behind

#region Convert XAML to Window
$window = Convert-XAMLtoWindow -XAML $xaml 
$window.ButBrowse.add_Click{
  # remove param() block if access to event information is not required
  param
  (
    [Parameter(Mandatory)][Object]$sender,
    [Parameter(Mandatory)][Windows.RoutedEventArgs]$e
  )
  
  $delimiter = $window.TxtDelimiter.Text
  
  $csv = Import-Csv -path (Get-FileName 'C:\git\BEPUG\meetups\20190522\Build GUIs to make your code look super expensive - Merlijn Van Waeyenberghe') -Delimiter $delimiter
  
}
$window.ButPickWinner.add_Click{
  # remove param() block if access to event information is not required
  param
  (
    [Parameter(Mandatory)][Object]$sender,
    [Parameter(Mandatory)][Windows.RoutedEventArgs]$e
  )
  
  $window.TxtWinner.Text = $csv.'Last Name' | Get-Random
}


#endregion


#region Manipulate Window Content
$window.TxtDelimiter.Text = ','

#endregion

# Show Window
$result = Show-WPFWindow -Window $window

#region Process results
if ($result -eq $true)
{
  [PSCustomObject]@{
  }
}
else
{
  Write-Warning 'User aborted dialog.'
}
#endregion Process results