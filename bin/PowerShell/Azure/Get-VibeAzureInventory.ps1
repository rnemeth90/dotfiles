<#
.SYNOPSIS
  Gets a list of all recently created resources across all subscriptions
  and send a report via email
.DESCRIPTION
    This script is hosted in an Azure Automation account.
.INPUTS
  None
.OUTPUTS
  Report sent via email
.NOTES
  Version:        1.0
  Author:         Ryan Nemeth
  Creation Date:  01/03/2021
  Purpose/Change: Initial script development
#>

#----------------------------------------------------------------#
# Initializations

$ErrorActionPreference = "SilentlyContinue"
$startDate = (Get-date).AddDays(-7)
$endDate = Get-Date


try{
    $aaCreds = Get-AutomationPSCredential -Name $azreadonly
    Write-output -inputobject "Got account creds for: [$AzROAccount]"
} Catch {
    write-error -Message "Could not get creds for account: [$AzROAccount] $_"
    return
}

#----------------------------------------------------------------#
# Functions

function Send-Email {
    param (
        # Parameter help description
        [Parameter(AttributeValues)]
        [ParameterType]$From,
        # Parameter help description
        [Parameter(AttributeValues)]
        [ParameterType]$To,
        # Parameter help description
        [Parameter(AttributeValues)]
        [ParameterType]$Subject,
        # Parameter help description
        [Parameter(AttributeValues)]
        [ParameterType]$Body
    )
    $SMTPUser =
    $smtpPassword =

    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force)
    $SMTPServer = "smtp.office365.com"
    Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $credentials
}

if (-not(Get-AzContext)) {
    Write-Output -InputObject "Connecting to AZ Account"
    Connect-AzAccount -Credential $aaCreds
}

Import-Module Az.Billing
$enabledSubs = Get-AzSubcription | where-object -Property "State" -eq "Enabled"

Write-Output -InputObject "`nUsing Date Range starting from $startDate to $endDate"

$OutputList = @()
if ($enabledSubs.count -gt 0) {
    foreach ($sub in $enabledSubs) {

        Set-AzContext -SubscriptionId -sub.id | Out-Null

        write-output -InputObject "`nGetting log based resources in subscription: [$($Sub.Name)] between: [$StartDate] and: [$EndDate]"
        $AllLogs = Get-AzLog -StartTime $StartDate -EndTime $EndDate -Status "Succeeded" -WarningAction "SilentlyContinue" -MaxRecord 10000
        write-output -InputObject "All logs count: [$($AllLogs.Count)]"
        $FilteredLogs = $AllLogs `
            | Select-Object SubmissionTimestamp, ResourceID, Caller, @{Name="OperationNamelocalizedValue"; Expression={$_.OperationName.localizedValue}}, @{Name="StatusValue"; Expression={$_.Status.Value}}, @{Name="OperationNameValue"; Expression={$_.OperationName.Value}}, @{Name="HttpVerb"; Expression={$_.HttpRequest.Method}}, @{Name="EventNameValue"; Expression={$_.EventName.Value}} `
            | Where-Object -FilterScript {$_.EventNameValue -EQ "EndRequest" -and $_.OperationNameValue -notlike "*audit*" -and $_.HttpVerb -ne "PATCH" -and $_.OperationNameValue -like "*write" -and $_.OperationNamelocalizedValue -notlike "Update *" -and $_.OperationNamelocalizedValue -notlike "*role assignment*"}
        write-output -InputObject "FilteredLogs logs count: [$($FilteredLogs.Count)]"
        $UniqueFilteredLogs = $FilteredLogs | Sort-Object -Property ResourceId -Unique
        write-output -InputObject "UniqueFilteredLogs logs count: [$($UniqueFilteredLogs.Count)]"

        write-output -InputObject "`nGetting tagged resources in subscription: [$($Sub.Name)] with Tag: CreatedBy."
        $resources = Get-AzResource -TagName "CreatedBy"
        write-output -InputObject "[$($resources.Count)] tagged resources retrieved."


        foreach ($resource in $resources) {
            write-output -InputObject "`nChecking resource: [$($resource.Name)]"
            $ResourceDate = Get-Date $resource.Tags.CreatedOnDate
        }

    }
}