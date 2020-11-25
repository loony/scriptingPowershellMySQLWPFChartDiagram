##########################################
# Created by Roland Jaggi, Joël Iselin, Michael Wettstein
# Description:
# Starting point to display the WPF window
##########################################

#Load required libraries
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing 
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. .\DbConnection.ps1

# WPF Window to create basis layout
$Global:AllChartsPath = $ScriptPath
[xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp2"

        Title="Combine Powershell and WPF together" Height="300" Width="300">
    <Grid>
        <Image Name='CornerImage' HorizontalAlignment="Left" VerticalAlignment="Top" Width="256" Margin="20,20,0,0" Opacity="0.5" />
        <Label Content="Powershell WPF MySQL" HorizontalAlignment="Center" Margin="10,100,0,0" VerticalAlignment="Top" Width="500" HorizontalContentAlignment="Center" FontSize="24" Foreground="SlateGray"/>
        <Label x:Name='TempLabel' Content="Latest 10 temperature inserts" HorizontalAlignment="Left" Margin="10,150,0,0" VerticalAlignment="Top" Width="396" HorizontalContentAlignment="Center" FontSize="18" Foreground="SlateGray"/>
        <WebBrowser x:Name='WebBrowser3' HorizontalAlignment="Left" Height="500" Margin="25,180,0,0" VerticalAlignment="Top" Width="1050"/>
    </Grid>
</Window>
"@

# Read the xaml grid and safe it to the reader
$Reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Form = [Windows.Markup.XamlReader]::Load($Reader)

# Find all controlls in the xaml to be able to communicate with it
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object { 
    New-Variable -Name $_.Name -Value $Form.FindName($_.Name) -Force 
}

    # Make juventus great again
    $CornerImage.Source = "$ScriptPath\PsScripts\juventusLogo.png"
    # Get path from the output folder
    $HtmlCharts = "$ScriptPath\htmlCharts"
    # Get temperature from the database
    $GetTemperature = GetTemperature
    $TemperatureValues = ""
    $MeasuredDateTimeValues = ""

    # Loop through the temperature and save them in a string to be able to display them on the chart
    foreach($row in $GetTemperature)
    {
        $TemperatureValues += "$($row.Temperature)," 
        $tempDate = $row.MeasuredDateTime.ToString("yyyy-MM-dd HH:mm:ss") # Time formating for most Europeans
        $MeasuredDateTimeValues += "'$($tempDate)',"
    }

    # Remove "," from the string otherwise it occures to an error because it will look for another value but does not find any
    $TemperatureValues = $TemperatureValues.Substring(0,$TemperatureValues.Length-1)
    $MeasuredDateTimeValues = $MeasuredDateTimeValues.Substring(0,$MeasuredDateTimeValues.Length-1)

    # Pass values to the chart creation function
    & "$ScriptPath\Psscripts\New-LineChart.ps1" -MeasuredDateTimeValues $MeasuredDateTimeValues -TemperatureValues $TemperatureValues -LegendLabel TemperatureLabel
    $WebBrowser3.Navigate("file:///$HtmlCharts\Line.html")

    # Window size
    $Form.Height="850" 
    $Form.Width="1200"

# Mandatory last line of every script to load form
[void]$Form.ShowDialog() 
