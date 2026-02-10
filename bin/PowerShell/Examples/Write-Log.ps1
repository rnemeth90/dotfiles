

#Function for writing to log file

$logfile = ".\playWithFunctions.log"

function writeLog(){
    param(
        [String]$value1,
        [String]$value2,
        [String]$value3,
        [String]$value4
    )

    $date = Get-Date -DisplayHint DateTime
    [String]$date + " " + $value1 + $value2 + $value3 + $value4 | Out-File $logfile -Append

}