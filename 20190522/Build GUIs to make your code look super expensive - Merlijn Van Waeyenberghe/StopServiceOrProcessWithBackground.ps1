#region XAML window definition
# Right-click XAML and choose WPF/Edit... to edit WPF Design
# in your favorite WPF editing tool
$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
   xmlns:d="http://schemas.microsoft.com/expression/blend/2008" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="d"
   MinWidth="200"
   Width ="400"
   SizeToContent="Height"
   Title="Service and Process Stopper"
   Topmost="True" WindowStyle="ThreeDBorderWindow"  Foreground="{x:Null}" d:DesignHeight="157.619" ResizeMode="NoResize" Icon="C:\Users\MerlijnVanWaeyenberg\Pictures\bepuglogo200_DYm_icon.ico">
    <Window.Background>
        <ImageBrush Opacity="0.5" ImageSource="C:\git\BEPUG\MeetupMay2019\it-background.jpg" Stretch="None"/>
    </Window.Background>
    <Window.Effect>
        <DropShadowEffect/>
    </Window.Effect>
    <Grid Margin="10,-14,10.333,-1">
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
        <TextBlock Grid.Column="1" Margin="10"><Run Text="Choose Service or Process to Stop:"/></TextBlock>

        <TextBlock Grid.Column="0" Grid.Row="1" Margin="5"><Run Text="Service"/></TextBlock>
        <ComboBox x:Name="ComboService" Grid.Column="1" Grid.Row="1" Margin="5"/>

        <TextBlock Grid.Column="0" Grid.Row="2" Margin="5"><Run Text="Process"/></TextBlock>
        <ComboBox x:Name="ComboProcess" Grid.Column="1" Grid.Row="2" Margin="5"/>

        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,10,0,0" Grid.Row="3" Grid.ColumnSpan="2">
            <Button x:Name="ButKillService" MinWidth="80" Height="22" Margin="5" Content="Stop Service"/>
            <Button x:Name="ButKillProcess" MinWidth="80" Height="22" Margin="5" Content="Stop Process"/>
            <Button x:Name="ButCancel" MinWidth="80" Height="22" Margin="5" Content="Cancel"/>
        </StackPanel>
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
$window.ButKillService.add_Click{
   # when clicked, take the selected item from the combo box and stop the service
   # using -whatif to just simulate for now
   # TODO: Remove -whatif in next line to actually stop a service
   $window.ComboService.SelectedItem | Stop-Service -WhatIf
   # update the combo box (if we really stopped a service, the list would now be shorter)
   $window.ComboService.ItemsSource = Get-Service | Where-Object Status -eq Running | Sort-Object -Property DisplayName
}

$window.ButKillProcess.add_Click{
  # remove param() block if access to event information is not required
  param
  (
    [Parameter(Mandatory)][Object]$sender,
    [Parameter(Mandatory)][Windows.RoutedEventArgs]$e
  )
  
  $window.ComboProcess.SelectedItem | Stop-Process -Force
  $window.ComboProcess.ItemsSource = Get-Process | Sort-Object -Property Name
}

$window.ButCancel.add_Click{
   # close window
   $window.DialogResult = $false
}

# fill the combobox with some powershell objects
$window.ComboService.ItemsSource = Get-Service | Where-Object Status -eq Running | Sort-Object -Property DisplayName
$window.ComboProcess.ItemsSource = Get-Process | where sessionid -eq 1 | Sort-Object -Unique -Property ProcessName
# tell the combobox to use the property "DisplayName" to display the object in its list
$window.ComboService.DisplayMemberPath = 'DisplayName'
$window.ComboProcess.DisplayMemberPath = 'ProcessName'
# tell the combobox to preselect the first element
$window.ComboService.SelectedIndex = 0
$window.ComboProcess.SelectedIndex = 0

Show-WPFWindow -Window $window
#endregion