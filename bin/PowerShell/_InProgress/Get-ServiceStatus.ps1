param(
    $Computer = "localhost",

    [Parameter(Mandatory=$True)]
    $ServiceName 
)

foreach($comp in $computer){
    $servStatus = Get-Service -ComputerName $comp -Name $serviceName
    if($servStatus -ne $NULL){
        Write-Host $serviceName.ToUpper() "FOUND ON" $comp.ToUpper() -ForegroundColor Green
    }
    else{
        Write-Host $serviceName.ToUpper() "NOT FOUND ON" $comp.ToUpper() -ForegroundColor Red
    }
}