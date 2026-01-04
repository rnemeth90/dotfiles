function Get-ErrorInformation {
    [cmdletbinding()]
    param($incomingError)

    if ($incomingError -and (($incomingError| Get-Member | Select-Object -ExpandProperty TypeName -Unique) -eq 'System.Management.Automation.ErrorRecord')) {

        Write-Host `n"Error information:"`n
        Write-Host `t"Exception type for catch: [$($IncomingError.Exception | Get-Member | Select-Object -ExpandProperty TypeName -Unique)]"`n 

        if ($incomingError.InvocationInfo.Line) {
        
            Write-Host `t"Command                 : [$($incomingError.InvocationInfo.Line.Trim())]"
        
        } else {

            Write-Host `t"Unable to get command information! Multiple catch blocks can do this :("`n

        }

        Write-Host `t"Exception               : [$($incomingError.Exception.Message)]"`n
        Write-Host `t"Target Object           : [$($incomingError.TargetObject)]"`n
    
    }

    Else {

        Write-Host "Please include a valid error record when using this function!" -ForegroundColor Red -BackgroundColor DarkBlue

    }

}