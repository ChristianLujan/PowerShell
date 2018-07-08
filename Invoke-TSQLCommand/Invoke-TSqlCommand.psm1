Function Invoke-TsqlCommand{
    [CmdletBinding()]
    Param([Parameter(Mandatory=$true,Position=0)]
          [string]$ServerName,
          [Parameter(Mandatory=$true,Position=1)]
          [string]$DbName,     
          [Parameter(Mandatory=$true,Position=2)]
          [string]$CommandText,       
          [int]$TimeOut=10  #10 seconds default timeout.         
         )               
    Try{
        #1. Build Connection & Command objects
        $connStr = "server=$($SQLServerName);database=$($DbName);Integrated Security=SSPI"
        $sqlConnection = [System.Data.SqlClient.SqlConnection]::new($connStr)

        $sqlCommand = [System.Data.SqlClient.SqlCommand]::new()
        $sqlCommand.CommandText = $CommandText       
        $sqlCommand.CommandTimeout = $TimeOut        
        $sqlCommand.Connection = $sqlConnection

        #2. Open data connection and execute command.
        Write-Verbose "Db connection opened."
        $sqlCommand.Connection.Open()

        #3. Load data into datatable from data reader.
        Write-Verbose "Executing SQL command."
        $reader = $sqlCommand.ExecuteReader()       
        $dt = [System.Data.DataTable]::new()
        $dt.Load($reader)  
    }   
    Catch{
        throw "Data retrieval error: $($_.Exception.Message)"
    }
    Finally{
        #4. Close all connections to database.
        if($reader.IsClosed -eq $false){                              
            [void] $reader.Close()
        }

        if($sqlCommand.Connection.State -ne 'Closed'){
            Write-Verbose "Db connection closed."                           
            [void] $sqlCommand.Connection.Close()            
        }
    }  
     #5. return data table to caller only if it has rows.
     if($dt.Rows.Count -gt 0){
        return ,$dt
     }   
<#
    .SYNOPSIS
        Invoke-TsqlCommand accepts various DDL and DML TSQL commands.
        It will return a data table if results are found for a given query, or it will return nothing otherwise.
#> 
}

Export-ModuleMember -Function Invoke-TsqlCommand
