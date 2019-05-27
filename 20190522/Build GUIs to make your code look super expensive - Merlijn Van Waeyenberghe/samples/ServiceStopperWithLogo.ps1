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
   Title="Service Stopper"
   Topmost="True">
    <Grid Margin="10,40,10,10">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <TextBlock Grid.Column="1" Margin="10">Choose Service to Stop:</TextBlock>

        <TextBlock Grid.Column="0" Grid.Row="1" Margin="5">Service</TextBlock>
        <ComboBox Name="ComboService" Grid.Column="1" Grid.Row="1" Margin="5"></ComboBox>

        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,10,0,0" Grid.Row="2" Grid.ColumnSpan="2">
            <Button Name="ButOk" MinWidth="80" Height="22" Margin="5">Stop Service</Button>
            <Button Name="ButCancel" MinWidth="80" Height="22" Margin="5">Cancel</Button>
        </StackPanel>
        <CheckBox Name="ChkWhatIf" Content="WhatIf" HorizontalAlignment="Left" Margin="90.667,17,0,0" Grid.Row="2" VerticalAlignment="Top" Grid.Column="1"/>
        <Button Name="ImgLogo" Grid.Column="1" HorizontalAlignment="Left" Margin="271.667,-35,0,0" VerticalAlignment="Top" Width="Auto" Height="Auto" BorderBrush="{x:Null}">
            <Image HorizontalAlignment="Left" Height="42" VerticalAlignment="Top" Width="45" Source="C:\Users\MerlijnVanWaeyenberg\Pictures\bepuglogo200.png"/>
        </Button>
    </Grid>
</Window>
'@

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

$window = Convert-XAMLtoWindow -XAML $xaml 

# add click handlers
$window.ButOk.add_Click{
  # when clicked, take the selected item from the combo box and stop the service
  # using -whatif to just simulate for now
  # TODO: Remove -whatif in next line to actually stop a service
  if($window.ChkWhatIf.IsChecked){$WhatIfPreference = $true}
  $window.ComboService.SelectedItem | Stop-Service
  # update the combo box (if we really stopped a service, the list would now be shorter)
  $window.ComboService.ItemsSource = Get-Service | Where-Object Status -eq Running | Sort-Object -Property DisplayName
  $WhatIfPreference = $false
  }

$window.ButCancel.add_Click{
  # close window
  $window.DialogResult = $false
}

$window.ImgLogo.add_Click{
  Start-Process "https://bepug.dev"
}

# fill the combobox with some powershell objects
$window.ComboService.ItemsSource = Get-Service | Where-Object Status -eq Running | Sort-Object -Property DisplayName
# tell the combobox to use the property "DisplayName" to display the object in its list
$window.ComboService.DisplayMemberPath = 'DisplayName'
# tell the combobox to preselect the first element
$window.ComboService.SelectedIndex = 0

Show-WPFWindow -Window $window
#endregion