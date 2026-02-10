<#
===============================================================================
DESCRIPTION : Exchange Mailbox Report
AUTHOR      : Luca Fabbri
VERSION     : 1.4 - Mailbox quota info fixed
			  1.3 - Total Deleted Item Size fixed
			  1.2 - Primary SMTP Address info added
			  1.1 - Mailbox quota info fixed
			  1.0 - Start
REQUIREMENTS: PowerShell 3.0, Exchange Management Shell
===============================================================================
#>

[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true,Position=1)]
    [string[]]$ServerNames
)

# Default template
$appName = $MyInvocation.MyCommand.Name.Substring(0,$MyInvocation.MyCommand.Name.LastIndexOf("."))
$appPath = Split-Path $MyInvocation.MyCommand.Definition
$outPath = $env:temp
$outFile = $outPath + "\" + $appName + ".csv"

# Prepare output collection
$return = @()

# Loop through Exchange Servers
ForEach ($ServerName in $ServerNames)
{
	# Initialize counter for progress bar
	$counter = 0

	# Loop through Exchange Server Mailboxes
	$Mailboxes = Get-Mailbox -Server $ServerName -ResultSize Unlimited -IgnoreDefaultScope -ErrorAction SilentlyContinue
	ForEach ($Mailbox in $Mailboxes)
	{
			# Increase counter for progress bar
			$counter++
			
			# Display progress bar
			Write-Progress -Activity "Getting Mailbox information" -Status "Processing Mailbox $Mailbox" -PercentComplete (100 * ($counter/@($Mailboxes).count))

			$userStatistics = Get-MailboxStatistics $Mailbox.Identity
			$userDatabase = Get-MailboxDatabase $Mailbox.Database
			
			$issueWarningQuota = if ($Mailbox.IssueWarningQuota.Value) {$Mailbox.IssueWarningQuota.Value.ToBytes() / 1GB} Else {"unlimited"}
			$prohibitSendQuota = if ($Mailbox.ProhibitSendQuota.Value) {$Mailbox.ProhibitSendQuota.Value.ToBytes() / 1GB} Else {"unlimited"}
			$prohibitSendReceiveQuota = if ($Mailbox.ProhibitSendReceiveQuota.Value) {$Mailbox.ProhibitSendReceiveQuota.Value.ToBytes() / 1GB} Else {"unlimited"}
			
			$totalItemSize = if ($userStatistics.TotalItemSize.Value) {$userStatistics.TotalItemSize.Value.ToKB()}
			$totalDeletedItemSize = if ($userStatistics.totalDeletedItemSize.Value) {$userStatistics.totalDeletedItemSize.Value.ToKB()}

			$Obj = New-Object PSObject
			$Obj | Add-Member NoteProperty -Name "MailboxName" -Value $Mailbox.Name
			$Obj | Add-Member NoteProperty -Name "PrimarySmtpAddress" -Value $Mailbox.PrimarySmtpAddress
			$Obj | Add-Member NoteProperty -Name "ExchangeUserAccountControl" -Value $Mailbox.ExchangeUserAccountControl
			$Obj | Add-Member NoteProperty -Name "Server" -Value $userDatabase.Server
			$Obj | Add-Member NoteProperty -Name "StorageGroup" -Value $userDatabase.StorageGroupName
			$Obj | Add-Member NoteProperty -Name "Database" -Value $userDatabase.Name
			$Obj | Add-Member NoteProperty -Name "UseDatabaseQuotaDefaults" -Value $Mailbox.UseDatabaseQuotaDefaults
			$Obj | Add-Member NoteProperty -Name "IssueWarningQuota(GB)" -Value ("{0:n2}" -f $issueWarningQuota)
			$Obj | Add-Member NoteProperty -Name "ProhibitSendQuota(GB)" -Value ("{0:n2}" -f $prohibitSendQuota)
			$Obj | Add-Member NoteProperty -Name "ProhibitSendReceiveQuota(GB)" -Value ("{0:n2}" -f $prohibitSendReceiveQuota)
			$Obj | Add-Member NoteProperty -Name "StorageLimitStatus" -Value $userStatistics.StorageLimitStatus
			$Obj | Add-Member NoteProperty -Name "TotalItemSize(KB)" -Value ("{0:n0}" -f $totalItemSize)
			$Obj | Add-Member NoteProperty -Name "ItemCount" -Value $userStatistics.ItemCount
			$Obj | Add-Member NoteProperty -Name "MailboxType" -Value $Mailbox.RecipientTypeDetails
			$Obj | Add-Member NoteProperty -Name "TotalDeletedItemSize(KB)" -Value ("{0:n0}" -f $totalDeletedItemSize)
					
			$return += $Obj
	}
	Write-Progress -Activity "Getting Mailbox information" -Status "Completed" -Completed
}

# Export output to csv
$return | Export-Csv -Path $outFile -Delimiter ";" -Force -noTypeInformation -Encoding UTF8
# Write-Output $return