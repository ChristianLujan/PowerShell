
Function Invoke-HelloWorld{
    param([string]$Name,[int]$SleepSeconds)
    Start-Sleep -Seconds $SleepSeconds
    return "Hello $($Name). I was asleep for $SleepSeconds seconds."
}



Function Invoke-HelloWorld_Async{
    [cmdletBinding()]
    Param([Parameter(Mandatory=$True,Position=0)]
          [PSObject[]]$InputObject                
          )

    Begin{
        #Create a RunSpace pool with 5 runspaces.  The pool will manage the    
        $minRunSpaces = 2
        $maxRunsSpaces = 5
        $runspacePool = [RunspaceFactory]::CreateRunspacePool($minRunSpaces, $maxRunsSpaces)	
        $runspacePool.ApartmentState = 'STA'   #MTA = Multithreaded apartment  #STA = Singl-threaded apartment.
        $runspacePool.Open()  #runspace pool must be opened before it can be used.       
        
    }

    Process{
        
    }

    End{

        $psCollection = foreach($object in $InputObject){
                            try{
                                $ps = [System.Management.Automation.PowerShell]::Create() 
                                $ps.RunspacePool = $runspacePool

                                #Add your custom functions to the [Automation.PowerShell] object.
                                #Add argument with parameter name for readability. You may just use AddArgument as an alternative but know your positional arguments.    
                                [void] $ps.AddScript(${function:Invoke-HelloWorld})
                                [void] $ps.AddParameter('Name',$object)        #Add parameterName,value
                                [void] $ps.AddParameter('SleepSeconds',8)  #Add parameterName,value
                                
                                #extend the ps management object to include AsyncResult and attach the AsyncResult object for receiving results at a later time.
                                $ps | Add-Member -MemberType NoteProperty -Name 'AsyncResult' -Value $ps.BeginInvoke()  #invoke asynchronously
                                $ps | Add-Member -MemberType ScriptMethod -Name 'GetAsyncResult' -Value {$this.EndInvoke($this.AsyncResult) } -PassThru
                               
                            }
                            catch{
                            throw $_
                            }
                        
                      }#end foreach

        $results = foreach($ps in $psCollection){
                        $ps.GetAsyncResult()  #yield results via pipeline.
                        [void] $ps.Dispose()
                   }

        If($runspacePool){
            [void] $runspacePool.Close()
            [void] $runspacePool.Dispose()
        }
        
        return $results
    }
}



Invoke-HelloWorld_Async -InputObject @('Joe','Jane','Jack')