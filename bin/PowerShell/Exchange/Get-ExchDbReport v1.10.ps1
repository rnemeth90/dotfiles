<#
===============================================================================
DESCRIPTION    : Exchange Database and Storage Report
AUTHOR         : Luca Fabbri
VERSION HISTORY: 1.10 - Database quota info fixed
				 1.9  - Storage Group/Database Circular Logging info added
					  - Offline Address Book & Public Folder info added
				 1.8  - Database quota info added
					  - Semantic changes
				 1.7  - Exchange 2010 support added
					  - Multiple source Exchange Servers as parameter added
				 1.6  - Mailbox count fixed
				 1.4  - Optimizations
				 1.3  - Transaction LOGs volume information added
				 1.2  - Progress bar added
				 1.0  - Start
REQUIREMENTS   : PowerShell 3.0, Exchange Management Shell, WMI Interface
===============================================================================
#>

[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true,Position=1)]
    [string[]]$ServerNames
)

# Get Volume information
Function Get-Volume ([string]$Path, [string]$ServerName) {
	Do
	{
		$parent = $Path -Replace "[^\\]*$"
		$Volume = Get-WmiObject -Class Win32_Volume -ComputerName $ServerName -Filter ("Name = '" + $parent.Replace("\","\\") + "'")
		$Path = $parent -Replace ".$"
		
	} While ($Volume -eq $null)
	return $Volume
}

# Default template
$appName = $MyInvocation.MyCommand.Name.Substring(0,$MyInvocation.MyCommand.Name.LastIndexOf("."))
$appPath = Split-Path $MyInvocation.MyCommand.Definition
$outPath = $env:temp
$outFile = $outPath + "\" + $appName + ".csv"

# Prepare output collection
$return = @()

# Convert dates to WMI CIM dates
$Tc = [System.Management.ManagementDateTimeconverter]
$evtTimeStart =$Tc::ToDmtfDateTime((Get-Date).AddDays(-1).Date)

# Create two calculated properties for InsertionStrings values  
$evtDb = @{Name="Db";Expression={$_.InsertionStrings[1]}}
$evtFreeMB = @{Name="FreeMB";Expression={[int]$_.InsertionStrings[0]}}

# Loop through Exchange Servers
ForEach ($ServerName in $ServerNames)
{
	# Initialize counter for progress bar
	$counter = 0
		
	# Loop through Exchange Server Databases
	$DBs = Get-MailboxDatabase -Server $ServerName | Sort-Object $_.EdbFilePath.PathName
	ForEach ($Db in $DBs)
	{
		# Get Transaction LOGs volume information (both Logical Drive and Mount Point): Name, Capacity, Free Space
		If ((Get-ExchangeServer $ServerName).AdminDisplayVersion -like "Version 8*") {
			# Exchange 2007
			$SG = Get-StorageGroup -Identity $($Db.StorageGroup)
			$logPath = "$($SG.LogFolderPath)\"
			$circularLogging = $($SG.CircularLoggingEnabled)
		} Else {
			$logPath = "$($Db.LogFolderPath)\"
			$circularLogging = $($Db.CircularLoggingEnabled)
		}
				
		$LogVolume = Get-Volume -Path $logPath -ServerName $ServerName
	
		$logVolumeCapacity = ($LogVolume.Capacity / 1GB)
		$logVolumeFreeSpace = ($LogVolume.FreeSpace / 1GB)

		# Increase counter for progress bar
		$counter++

		# Display progress bar
		Write-Progress -Activity "Getting Database information" -Status "Processing Database $Db" -PercentComplete (100 * ($counter/@($DBs).count))

		# Get DB volume information (both Logical Drive and Mount Point): Name, Capacity, Free Space
		$dbFilePath = $Db.EdbFilePath.PathName
		$DbVolume = Get-Volume -Path $dbFilePath -ServerName $ServerName
		
		# Get DBs file size information
		$DbFile = Get-WmiObject -Class CIM_LogicalFile -ComputerName $ServerName -Filter ("Name = '" + $dbFilePath.Replace("\","\\") + "'")
		
		# Count DB mailboxes
		#$mailboxCount = Get-MailboxStatistics -Database $Db.Identity | Where-Object {$_.DisconnectDate -eq $null -and $_.ObjectClass -eq "Mailbox"} | Measure-Object
		$mailboxCount = Get-MailboxStatistics -Database $Db.Identity | Where-Object {$_.DisconnectDate -eq $null -and $_.ObjectClass -NotMatch "(SystemAttendantMailbox|ExOleDbSystemMailbox)"} | Measure-Object
		
		# Count disconnected DB mailboxes
		$disconnectedMailboxCount = Get-MailboxStatistics -Database $Db.Identity | Where-Object {$_.DisconnectDate -ne $null} | Measure-Object

		# Get latest DB free space information from Application Events Log (Event ID 1221)
		$dbName = $Db.Identity.Parent.Name + "\" + $Db.Identity.Name
		$DbFreeSpace = Get-WMIObject Win32_NTLogEvent -ComputerName $ServerName -Filter `
		"LogFile = 'Application' AND EventCode = 1221 AND TimeWritten > '$evtTimeStart'" | `
		Where-Object {$_.InsertionStrings[1] -eq $dbName} | Select-Object $evtDb, $evtFreeMB -First 1 | Sort-Object TimeWritten, FreeMB –Unique –Descending
		
		$dbVolumeCapacity = ($DbVolume.Capacity / 1GB)
		$dbVolumeFreeSpace = ($DbVolume.FreeSpace / 1GB)
		$dbFreeSpace = ($DbFreeSpace.FreeMB / 1KB)
		
		$Obj = New-Object PSObject
		$Obj | Add-Member NoteProperty -Name "DbVolumeName" -Value $DbVolume.Name
		$Obj | Add-Member NoteProperty -Name "DbVolumeCapacity(GB)" -Value ("{0:n2}" -f $dbVolumeCapacity)
		$Obj | Add-Member NoteProperty -Name "DbVolumeFreeSpace(GB)" -Value ("{0:n2}" -f $dbVolumeFreeSpace)
		$Obj | Add-Member NoteProperty -Name "DbVolumeFree%" -Value ("{0:n2}" -f ($dbVolumeFreeSpace / $dbVolumeCapacity * 100))
		$Obj | Add-Member NoteProperty -Name "DbVolumeTotalFree(GB)" -Value ("{0:n2}" -f ($dbVolumeFreeSpace + $dbFreeSpace))
		$Obj | Add-Member NoteProperty -Name "Server\StorageGroup\Database" -Value $Db.Identity
		$Obj | Add-Member NoteProperty -Name "DbFileSize(GB)" -Value ("{0:n2}" -f ($DbFile.FileSize / 1GB))
		$Obj | Add-Member NoteProperty -Name "DbFreeSize(GB)" -Value ("{0:n2}" -f $dbFreeSpace)
		$Obj | Add-Member NoteProperty -Name "IssueWarningQuota(GB)" -Value ("{0:n2}" -f ($Db.IssueWarningQuota.Value.ToBytes() / 1GB))
		$Obj | Add-Member NoteProperty -Name "ProhibitSendQuota(GB)" -Value ("{0:n2}" -f ($Db.ProhibitSendQuota.Value.ToBytes() / 1GB))
		$Obj | Add-Member NoteProperty -Name "ProhibitSendReceiveQuota(GB)" -Value ("{0:n2}" -f ($Db.ProhibitSendReceiveQuota.Value.ToBytes() / 1GB))
		$Obj | Add-Member NoteProperty -Name "UserMailboxCount" -Value $mailboxCount.Count
		$Obj | Add-Member NoteProperty -Name "DisconnectedMailboxCount" -Value $disconnectedMailboxCount.Count
		$Obj | Add-Member NoteProperty -Name "LogVolumeName" -Value $LogVolume.Name
		$Obj | Add-Member NoteProperty -Name "LogVolumeCapacity(GB)" -Value ("{0:n2}" -f $logVolumeCapacity)
		$Obj | Add-Member NoteProperty -Name "LogVolumeFreeSpace(GB)" -Value ("{0:n2}" -f $logVolumeFreeSpace)
		$Obj | Add-Member NoteProperty -Name "LogVolumeFree%" -Value ("{0:n2}" -f ($logVolumeFreeSpace / $logVolumeCapacity * 100))
		$Obj | Add-Member NoteProperty -Name "OfflineAddressBook" -Value $Db.OfflineAddressBook
		$Obj | Add-Member NoteProperty -Name "PublicFolderDatabase" -Value $Db.PublicFolderDatabase
		$Obj | Add-Member NoteProperty -Name "CircularLoggingEnabled" -Value $circularLogging
		
		$return += $Obj
	}
	Write-Progress -Activity "Getting Database information" -Status "Completed" -Completed
}
	
# Export output to csv
$return | Export-Csv -Path $outFile -Delimiter ";" -Force -noTypeInformation -Encoding UTF8
# Write-Output $return | Select-Object DbVolumeName, "DbVolumeFreeSpace(GB)", "DbFileSize(GB)", "DbFreeSize(GB)", UserMailboxCount, LogVolumeName, "LogVolumeFreeSpace(GB)"