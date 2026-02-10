Param(
    [Parameter(Mandatory=$false)]
    [String]$file,
    [Parameter(Mandatory=$false)]
    [string]$server    
)

if($file -ne $null){
    $servers = Get-Content $file
    foreach($s in $servers){
        if(Test-Connection $s -Count 2 -Quiet -ErrorAction SilentlyContinue){
            Write-Host "Testing Connection to: " $s
            Get-WmiObject win32_Service -Computer $s | where {$_.DisplayName -match "SQL Server"} | select SystemName, DisplayName, Name, State, Status, StartMode, StartName  | Out-File servers.csv
        }
    }
}
elseif(Test-Connection $server -Count 2 -Quiet -ErrorAction SilentlyContinue){
    
    Get-WmiObject win32_Service -Computer $server | where {$_.DisplayName -match "SQL Server"} | select SystemName, DisplayName, Name, State, Status, StartMode, StartName | out-file servers.csv
}

