param(
    # The script to run on the remote computers
    [Parameter(Mandatory=$false)]
    [String]$Script,
    # The computers to run the script on
    [Parameter(Mandatory=$false)]
    [String]$RemoteComputers
)

#Get admin creds
$cred = Get-Credential
$Computers = Get-Content .\computers.txt | ForEach-Object { $_ -split ',' }

foreach ($computer in $Computers) {
    wmic /failfast:on /node:$computer product where name="Umbrella Roaming Client" call uninstall /nointeractive
}