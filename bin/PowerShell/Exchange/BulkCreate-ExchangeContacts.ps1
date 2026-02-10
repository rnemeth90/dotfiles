<#
    .SYNOPSIS 
     This script will create Exchange Mail Contacts based on entries in a csv. This script accepts three parameters. 
     The file parameter is used to specify the location of the $csv file containing the users for which you would 
     like to create mail contacts. The ConnectionUri parameter is used to specify the URL of the PowerShell virtual 
     directory on your Exchange server. The Online parameter should be used if you are working with Exchange Online. 
     The connectionUri and Online parameters should not be used together, you only need one or the other.
    .EXAMPLE
     BulkCreate-ExchangeContacts.ps1 -File <Path to CSV> -Online $True
    .EXAMPLE
     BulkCreate-ExchangeContacts.ps1 -File <Path to CSV> -ConnectionUri <URL of PowerShell Virtual Directory on your Exchange Server>
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 2017.05.04.01
#>

####################
#### Parameters ####
####################
param(
    [Parameter(Mandatory=$True)]
    [String]$File,
    [Parameter(Mandatory=$False)]
    [String]$ConnectionUri,
    [Parameter(Mandatory=$False)]
    [String]$Online
)

#http://sbdmsxp02.ecimain.ecipay.com/powershell
#https://ps.outlook.com/powershell

###################
#### Variables ####
###################
$csv = $File
$mbs = Import-Csv $csv
$logfile = ".\BulkCreate-ExchangeContacts.log"
$computerName = $env:ComputerName
$username = $env:USERNAME

###################
#### Functions ####
###################
function writeLog(){
    param(
        [Parameter(Mandatory=$True)]
        [String]$value1
    )

    $date = Get-Date -DisplayHint DateTime
    [String]$date + " " + $value1 | Out-File $logfile -Append

}

function Connect-ExchangeOnPrem(){
    $cred = Get-Credential
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUri -Credential $cred -Authentication Default -AllowRedirection
    Import-PSSession $session
    Clear-Host
    return
}

function Connect-ExchangeOnline(){
    $cred = Get-Credential
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic -AllowRedirection
    Import-PSSession $session
    Clear-Host
    return
}

function Main_Online(){
    ForEach($mb in $mbs){
        $exchangeServer = Get-PSSession | Select-Object computername
        $name = $null
        $name = $mb.firstName + " " + $mb.lastName
        New-MailContact -Name $name -ExternalEmailAddress $mb.externalEmailAddress | Out-Null
        Write-Host "Creating contact for $name" -ForegroundColor Green
        writeLog "****"
        writeLog "**** Creating contact for $name on server $exchangeServer"
        writeLog "**** Ran on $computerName by $username"
    }
    return
}

function Main_OnPrem{
    ForEach($mb in $mbs){
        $exchangeServer = Get-PSSession | Select-Object computername
        $name = $null
        $name = $mb.firstName + " " + $mb.lastName
        New-MailContact -Name $name -ExternalEmailAddress $mb.externalEmailAddress -OrganizationalUnit $mb.organizationalUnit | Out-Null
        Write-Host "Creating contact for $name" -ForegroundColor Green
        writeLog "****"
        writeLog "**** Creating contact for $name on server $exchangeServer"
        writeLog "**** Ran on $computerName by $username"
    }
    return
}

###################
###### Logic ######
###################
$checkConnection = Get-PsSession | Where-Object ConfigurationName -eq "Microsoft.Exchange" -ErrorAction SilentlyContinue
if($Online){
    if($checkConnection -eq $null){
        Connect-ExchangeOnline
        Main_Online
    }
    else{
        continue
    }
}
else{
    if($checkConnection -eq $null){
        Connect-ExchangeOnPrem
        Main_OnPrem 
    }
    else{
        continue
    }
}

#Remove the session with the Exchange server
Get-PSSession | Remove-PSSession

###################
###### To do ######
###################
# Add error checking
# Add "What if" Mode