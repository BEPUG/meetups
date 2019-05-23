

$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
   Width="525"
   SizeToContent="Height"
   Title="Hover Example" Topmost="True">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <TextBox Name="Textbox" Height="120" Grid.Row="0" TextWrapping="Wrap" Margin="5"  HorizontalAlignment="Stretch" VerticalAlignment="Top" />
        <Button Name="OK" Width="80" Height="25" Grid.Row="1"  HorizontalAlignment="Right" Margin="5" VerticalAlignment="Bottom">OK</Button>
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
        [Parameter(Mandatory)]
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


$window.TextBox.add_MouseLeave{
    $window.TextBox.Text = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String('VGhhbmsgeW91IGZvciBhdHRlbmRpbmch'))
  }

$window.TextBox.add_MouseEnter{
    $window.TextBox.Text = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String('WU9VIGdldCBhIGJlZXIh'))
  }
$window.OK.add_Click{
    $window.DialogResult = $true
}

$window.TextBox.Text = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String('VGhhbmsgeW91IGZvciBhdHRlbmRpbmch'))

$null = Show-WPFWindow -Window $window

