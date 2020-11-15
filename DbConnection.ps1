function GetTemperature {
    $MySQLAdminUserName = 'air_live'
    $MySQLAdminPassword = 'juventus'
    $MySQLDatabase = 'air_live'
    $MySQLHost = '127.0.0.1'
    $ConnectionString = "server=" + $MySQLHost + ";port=3306;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase
    $Query = "SELECT temperature, MeasuredDateTime FROM(SELECT temperature, MeasuredDateTime FROM temperature ORDER BY MeasuredDateTime DESC LIMIT 10) AS TempAndDate ORDER BY MeasuredDateTime"

    

    Try {
	    [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
	    $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
	    $Connection.ConnectionString = $ConnectionString
	    $Connection.Open()
	    $Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query, $Connection)
	    $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
	    $DataSet = New-Object System.Data.DataSet
	    $RecordCount = $dataAdapter.Fill($dataSet, "data")
	    return $DataSet.Tables[0]
    }
    Catch {
	    Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
    }
    Finally {
	    $Connection.Close()
    }
}