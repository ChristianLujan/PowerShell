# About Invoke-TSqlCommand

Invoke-TSqLCommand is a module targeted for standalone data-connected PowerShell scripting solutions or may be used as a productivity tool too. The code base was kept small for conciseness for new PowerShell users and utilizes ADO.Net. 

## Goal of Invoke-TSqlCommand

Invoke-TSqlCommand may utilize any DDL or DML commands (Select, Insert, Update, Delete, ect) that a user has privileges to execute.  This function returns a System.Data.DataTable object—for a non empty result set—or nothing (null) otherwise.

### Prerequisites

 The Microsoft .Net Platform 3.5+ and PowerShell Version 3+ is required.


### Sample Use

Import the module from your local client script. In the example below, I have chosen to place the script in the same folder as the module and using the $PSScriptRoot variable path to reference the parent directory.

```
Import-Module "$PSScriptRoot\Invoke-TSqlCommand.psm1" 
```

I want to insert two names into a fictional Person table.  I have used the OUTPUT command to return the two rows back to the my calling script so I can further process them; for example, writing a message back to the console reporting they were inserted successfully.

```
$commandText = @"                
                 Insert into dbo.Person(name)
                 OUTPUT Inserted.name
                 Values ('Jack'),('Jill');            
"@

$results = Invoke-TsqlCommand -ServerName '<Server>' -DbName '<database>' -CommandText $commandText

#Write results back to console.
$results | Foreach-Object { Write-Host "$($_.name) was successfully inserted into Person table." }
```


## Word of Caution

If you are considering using this with automation, consider creating a signed-certificate for this file and secure it in a location only accessible by administrators—especially if the service account executing the script has write access. 
