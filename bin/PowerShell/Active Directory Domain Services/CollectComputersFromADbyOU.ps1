#This script gets run from the DC
#Import modules required for this script
Import-Module ActiveDirectory

#Setup Variables
$ou = @() #Holds ou to query
$dc = @() #Holds name of domain controller
$computerList = @() #Holds computers to query
$result = @() #Holds the output

$dc = $env:COMPUTERNAME
$ou = Read-Host "What OU would you like to scan for computers? (if left blank it will scan all OU's)"  #Prompts user for OU to scan for computers
$outFile = "\\${dc}\DomainJoin\ADCompResults.txt" #File to create for successful queries

#populate the list of computers to query with a filter
$computerList = Get-ADComputer -Filter * | where {$_.enabled -eq "true"} | where {$_.DistinguishedName -like "*OU=$ou*"} | Select-Object Name

#Manual way to create a list for debug
#$computerList = 'DMAGEE-WIN8' #change to a test computer
#$computerList  #used to debug pipe list

Foreach($computer in $computerList)
{
    #Turn the computer object into strings and trim off any space
    [string]$computerName = $computer.name
    #$computerName = $computerName.trim()     
        $result += $computerName
}
Write-Output $result
$result | Out-File $outFile