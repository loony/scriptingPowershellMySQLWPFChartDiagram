##########################################
# Created by Roland Jaggi, Joël Iselin, Michael Wettstein
# Description:
# This script is creating line chart diagram 
# by passing values 
##########################################

# Define function parameters
Param
(
    [parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]$MeasuredDateTimeValues,
    [parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]$TemperatureValues,
    [parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
    [string]$LegendLabel
)

# Creating the html chart, add all the necessary js scripts to create the chart, using bootstrap for styling
$Chart = @"
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.6.0/Chart.min.js"></script>
        <script src="JSScripts/Chart.min.js"></script>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <link rel="stylesheet" href="JSScripts/bootstrap.min.css">
        <title>Line Chart</title>
    </head>
    <body>
        <div class="container">
            <canvas id="lineChartDiagramm"></canvas>
        </div>
        <script>
            let lineChartDiagramm = document.getElementById('lineChartDiagramm').getContext('2d');
            Chart.defaults.global.defaultFontSize = 12;
            Chart.defaults.global.defaultFontColor = '#777';
            
            let massPopChart = new Chart(lineChartDiagramm, {
              type:'line', 
              data:{
                labels:[$MeasuredDateTimeValues],
                datasets:[{
                  label: `"$LegendLabel`" ,
                  data:[$TemperatureValues],
                  backgroundColor:'rgba(0,191,255, 0.6)',
                  hoverBackgroundColor: 'rgba(255,165,0, 0.6)',
                  borderWidth:1,
                  borderColor:'#777',
                  hoverBorderWidth:3,
                  hoverBorderColor:'#000',
                  fontsize:10,
                }]
              },
              options:{
                title:{
                  display:false,
                  fontSize:8
                },
                legend:{
                  display:false,
                  position:'bottom',
                  labels:{
                    fontColor:'Gray',
                    fontSize:12,
                  }
                },
                layout:{
                  padding:{
                    left:0,
                    right:0,
                    bottom:0,
                    top:0
                  }
                },
                tooltips:{
                  enabled:true,
                  titleFontSize:10
                },
                
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: false,
                            display: true,
                            fontSize:10,
                        },
                        gridLines: {
                            display:true,
                            drawBorder: true,
                        }
                    }],
                    xAxes: [{
                        // Change here
                        barPercentage: 1,
                        ticks:{
                            fontSize: 12, 
                            display: true,
                        },
                        gridLines: {
                            display:true, 
                            drawBorder: true,
                        }
                    }]
                }		
              }
            });
        </script>
    </body>
</html>
"@

# Create html file with all the above informations
$Chart | Out-File -FilePath $Global:AllChartsPath\HtmlCharts\Line.html
