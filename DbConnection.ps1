##########################################
# Created by Roland Jaggi, Joël Iselin, Michael Wettstein
# Description:
# Basic database connection to a MySQL database
##########################################

function GetTemperature {
    $MySQLAdminUserName = 'air_live'
    $MySQLAdminPassword = 'juventus'
    $MySQLDatabase = 'air_live'
    $MySQLHost = '127.0.0.1'
    $ConnectionString = "server=" + $MySQLHost + ";port=3306;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase
    $Query = "SELECT temperature, MeasuredDateTime FROM(SELECT temperature, MeasuredDateTime FROM temperature ORDER BY MeasuredDateTime DESC LIMIT 10) AS TempAndDate ORDER BY MeasuredDateTime"

    # Establish connection to the database and return values
    Try {
        # load connector
	    [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
        $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
        # Establish connection
	    $Connection.ConnectionString = $ConnectionString
        $Connection.Open()
        # perform sql query 
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
        # Close open connection to the database
	    $Connection.Close()
    }
}