##########################################
# Created by http://vcloud-lab.com
# Created using chart.js html
# Tested on Windows 10
##########################################
#Load required libraries
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing 
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
#$AssemblyLocation = Join-Path -Path $ScriptPath -ChildPath Charts

$Global:AllChartsPath = $ScriptPath
[xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp2"

        Title="Combine Powershell and WPF" Height="300" Width="300">
    <Grid>
        <Grid.Background>Azure</Grid.Background>
        <Image Name='CornerImage' HorizontalAlignment="Left" VerticalAlignment="Top" Width="256" Margin="20,20,0,0" />
        <Label x:Name='TempLabel' Content="Latest 10 Temperature inserts" HorizontalAlignment="Left" Margin="10,150,0,0" VerticalAlignment="Top" Width="396" HorizontalContentAlignment="Center" FontSize="18" Foreground="SlateGray"/>
        <WebBrowser x:Name='WebBrowser3' HorizontalAlignment="Left" Height="500" Margin="25,180,0,0" VerticalAlignment="Top" Width="1050"/>
    </Grid>
</Window>
"@
#Imports
. .\DbConnection.ps1
#Read the form
$Reader = (New-Object System.Xml.XmlNodeReader $xaml) 
$Form = [Windows.Markup.XamlReader]::Load($reader) 

#AutoFind all controls
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object { 
    New-Variable -Name $_.Name -Value $Form.FindName($_.Name) -Force 
}

$CornerImage.Source = "$ScriptPath\PsScripts\juventusLogo.png"

$HtmlCharts = "$ScriptPath\htmlCharts"

    $GetTemperature = GetTemperature
    $TemperatureValues = ""
    $MeasuredDateTimeValues = ""

    foreach($row in $GetTemperature)
    {
        $TemperatureValues += "$($row.Temperature)," 
        $tempDate = $row.MeasuredDateTime.ToString("yyyy-MM-dd HH:mm:ss")
        $MeasuredDateTimeValues += "'$($tempDate)',"
    }

    $TemperatureValues = $TemperatureValues.Substring(0,$TemperatureValues.Length-1)
    $MeasuredDateTimeValues = $MeasuredDateTimeValues.Substring(0,$MeasuredDateTimeValues.Length-1)
    $OutputLabel.Content = $MeasuredDateTimeValues

    # Write-Output $GetTemperature
    # $Label1.Content = "$((Get-WmiObject Win32_PhysicalMemory -ComputerName $ComputerName.Text | Select-Object -ExpandProperty Capacity | Measure-Object -Sum).Sum / 1GB)" + " GB"
    # $Label2.Content = $(Get-WmiObject Win32_Processor -ComputerName $ComputerName.Text).NumberOfLogicalProcessors
    # $Label3.Content = "$([System.Math]::Round((get-wmiobject Win32_DiskDrive -ComputerName $ComputerName.Text).size / 1gb))" + " GB"
    # $Label4.Content = (Get-WmiObject win32_NetworkAdapter -ComputerName $ComputerName.Text | Where-Object {$_.PhysicalAdapter}).Count

    $AllProcesses = Get-Process -ComputerName $ComputerName.Text
    $ProcessByCpu = $AllProcesses | Group-object -Property Name
    $Top5ProcessesByCPU = $ProcessByCpu | Select-Object Name, @{N='CpuUsage';E={$_.Group.cpu | Measure-Object -Sum | Select-Object -ExpandProperty Sum}} | Sort-Object -Property CpuUsage -Descending | Select-Object -First 10
    $TopCpuNames = ($Top5ProcessesByCPU.Name | ForEach-Object {"'{0}'" -f $_}) -join ', '
    $TopCpuUsage = ($Top5ProcessesByCPU | Select-Object -ExpandProperty CpuUsage) -join ', '
    & "$ScriptPath\Psscripts\New-LineChart.ps1" -TopCpuNames $MeasuredDateTimeValues -TopCpuUsage $TemperatureValues -LegendLabel CpuUsage
    $WebBrowser3.Navigate("file:///$HtmlCharts\Line.html")

    $Form.Height="850" 
    $Form.Width="1200"

    $ProcessByCount = $AllProcesses| Group-Object -Property Name | Sort-Object -Property Count -Descending | Select-Object -First 5
    $Top5ProcName = ($ProcessByCount.Name | ForEach-Object {"'{0}'" -f $_}) -join ', '
    $Top5ProcCount = ($ProcessByCount | Select-Object -ExpandProperty Count) -join ', '
    & "$ScriptPath\Psscripts\New-BarChart.ps1" -Top5ProcName $Top5ProcName -Top5ProcCount $Top5ProcCount -LegendLabel Count
    $WebBrowser2.Navigate("file:///$HtmlCharts\Bar.html")

    $AllServices = Get-Service -ComputerName $ComputerName.Text
    $ServicesByCount = $AllServices | Group-Object -Property Status
    $ServicesNames = ($ServicesByCount.Name | ForEach-Object {"'{0}'" -f $_}) -join ', '
    $ServicesStatusCount = ($ServicesByCount | Select-Object -ExpandProperty Count) -join ', '
    & "$ScriptPath\Psscripts\New-DoughnutChart.ps1" -ServicesNames $ServicesNames -ServicesCount $ServicesStatusCount -LegendLabel Status
    $WebBrowser1.Navigate("file:///$HtmlCharts\Doughnut.html")

#Mandetory last line of every script to load form
[void]$Form.ShowDialog() 
