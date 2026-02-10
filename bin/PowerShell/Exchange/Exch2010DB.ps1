#####################################################################################
# Exchange 2010 Mailbox Database HTML Email Report
# Script gathers below information
# 1. Server currently hosting the Database.
# 2. Database Size
# 3. Database file path
# 4. Number of users in the Database.
# 5. Amount of Whitespace
# 6. Top Mailbox in the Database and the size of it.
# 7. Last Backup time and days since last backup.
# ###################################################################################
# It then generates HTML Files for this.
# You can setup Threshold in the script,below are the items which can have threshold
# 1. Number of Mailboxes
# 2. Database Size
# 3. How old a Backup can be
# 4. Top Mailbox Size
# If any one of the above threshold is reached the configured threshold.
# It will be marked as red in the HTML.
#####################################################################################
New-Item -ItemType file -Path C:\Windows\temp -Name dbreport.htm
$mailboxCountThreshold =  30
$dbSizeThreshold = 10GB
$backupThreshold = 1
$mbxSizeThreshold = 30MB
$fileName = "DBReport.htm"
Function writeHtmlHeader
{
param($fileName)
$date = ( Get-Date ).ToString('yyyy/MM/dd')
Add-Content $fileName "<html>"
Add-Content $fileName "<head>"
Add-Content $fileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
Add-Content $fileName '<title>Exchange Database Report</title>'
Add-Content $fileName '<STYLE TYPE="text/css">'
Add-Content $fileName  "<!--"
Add-Content $fileName  "td {"
Add-Content $fileName  "font-family: Tahoma;"
Add-Content $fileName  "font-size: 11px;"
Add-Content $fileName  "border-top: 1px solid #999999;"
Add-Content $fileName  "border-right: 1px solid #999999;"
Add-Content $fileName  "border-bottom: 1px solid #999999;"
Add-Content $fileName  "border-left: 1px solid #999999;"
Add-Content $fileName  "padding-top: 0px;"
Add-Content $fileName  "padding-right: 0px;"
Add-Content $fileName  "padding-bottom: 0px;"
Add-Content $fileName  "padding-left: 0px;"
Add-Content $fileName  "}"
Add-Content $fileName  "body {"
Add-Content $fileName  "margin-left: 5px;"
Add-Content $fileName  "margin-top: 5px;"
Add-Content $fileName  "margin-right: 0px;"
Add-Content $fileName  "margin-bottom: 10px;"
Add-Content $fileName  ""
Add-Content $fileName  "table {"
Add-Content $fileName  "border: thin solid #000000;"
Add-Content $fileName  "}"
Add-Content $fileName  "-->"
Add-Content $fileName  "</style>"
Add-Content $fileName "</head>"
Add-Content $fileName "<body>"
Add-Content $fileName  "<table width='100%'>"
Add-Content $fileName  "<tr bgcolor='#CCCCCC'>"
Add-Content $fileName  "<td colspan='7' height='25' align='center'>"
Add-Content $fileName  "<font face='tahoma' color='#003399' size='4'><strong>Exchange Database Report - $date</strong></font>"
Add-Content $fileName  "</td>"
Add-Content $fileName  "</tr>"
Add-Content $fileName  "</table>"
}
# Function to write the HTML Header to the file
Function writeTableHeader
{
param($fileName)
Add-Content $fileName "<table width='100%'><tbody>" 
Add-Content $fileName "<tr bgcolor=#CCCCCC>"
Add-Content $fileName "<td width='10%' align='center'>Database Name</td>"
Add-Content $fileName "<td width='10%' align='center'>Server</td>"
Add-Content $fileName "<td width='15%' align='center'>Database File</td>"
Add-Content $fileName "<td width='10%' align='center'>Database Size(MB)</td>"
Add-Content $fileName "<td width='7%' align='center'># of Mailboxes</td>"
Add-Content $fileName "<td width='10%' align='center'>WhiteSpace(MB)</td>"
Add-Content $fileName "<td width='10%' align='center'>Top Mailbox</td>"
Add-Content $fileName "<td width='10%' align='center'>Top Mailbox Size</td>"
Add-Content $fileName "<td width='10%' align='center'>Last Full Backup</td>"
Add-Content $fileName "<td width='15%' align='center'>No Backup Since?</td>"
Add-Content $fileName "</tr>"
}

Function writeHtmlFooter
{
param($fileName)
Add-Content $fileName "</table>"
Add-Content $fileName "</body>"
Add-Content $fileName "</html>"
}

Function get-DBInfo
{
 $dbs = Get-MailboxDatabase -Status
 foreach($db in $dbs)
 {
 	$name = $db.name
	$svr = $db.servername	
	$edb = $db.edbfilepath	
	$edbSize = $db.DatabaseSize.Tobytes()
	$whiteSpace = $db.AvailableNewMailboxSpace.Tobytes()/1mb
	$mbxCount = (Get-Mailbox -Database $db).count
	$topMailbox = Get-Mailbox -Database $db | Get-MailboxStatistics | Sort-Object TotalItemSize -Descending |Select-Object DisplayName -First 1 | Format-Table Displayname -HideTableHeaders | Out-String
	$topMailboxSize = Get-Mailbox -Database $db| Get-MailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object totalitemsize -First 1
    $topMailboxSize = $topMailboxSize.TotalItemSize.Value.ToBytes()
	$lastBackup =  $db.LastFullBackup; $currentDate = Get-Date
	if ($lastBackup -eq $null)
	{	
	 $howOldBkp =  $null	 
	}
	else
	{
	$howOldBkp = $currentDate - $lastBackup	
	$howOldBkp = $howOldBkp.days	
	}
	writedata $name $svr $edb $edbSize $whiteSpace $mbxCount $topMailbox $topMailboxSize $lastBackup $howOldBkp
}
 
}

Function WriteData
{
param($name,$svr,$edb,$edbSize,$whiteSpace,$mbxCount,$topMailbox,$topMailboxSize,$lastBackup,$howOldBkp)

$tableEntry = "<tr><td>$name</td><td>$svr</td><td>$edb</td>"
#Checking if EDB size is greater than the set  Threshold
#If it is greater than the table cell will be marked red, else green.
if ($edbSize -gt $dbSizeThreshold)
{
 $edbSize = $edbSize/1mb
 $tableEntry += "<td bgcolor='#FF0000' align=center>$edbSize</td>"
}
else
{
 $edbSize = $edbSize/1mb
 $tableEntry += "<td bgcolor='#387C44' align=center>$edbSize</td>"
}
#Checking if mailbox count is greater than configured threshold
if ($mbxCount -gt $mailboxCountThreshold)
{
 $tableEntry += "<td bgcolor='#FF0000' align=center>$mbxCount</td>"
}
else
{
 $tableEntry += "<td bgcolor='#387C44' align=center>$mbxCount</td>"
}
$tableEntry +=  "<td>$whiteSpace</td>"
$tableEntry +=  "<td>$topMailbox</td>"
#Checking if mailbox count threshold is exceeded or not
if ($topMailboxSize -gt $mbxSizeThreshold)
{
 $topMailboxSize = $topMailboxSize/1mb ; $topMailboxSize =[Math]::Round($topMailboxSize,2)
 $tableEntry += "<td bgcolor='#FF0000' align=center>$topMailboxSize</td>"
}
else
{
 $topMailboxSize = $topMailboxSize/1mb ; $topMailboxSize =[Math]::Round($topMailboxSize,2)
 $tableEntry += "<td bgcolor='#387C44' align=center>$topMailboxSize</td>"
}
#Checking how old is the backup

if ($howOldBkp -eq $null)
{

 $tableEntry += "<td bgcolor='#FF0000' align=center> null </td>"
 $tableEntry += "<td bgcolor='#FF0000' align=center>Never Backed Up</td>"
}
elseif ($howOldBkp -le $backupThreshold)
{
 $tableEntry += "<td bgcolor='#387C44' align=center>$lastbackup</td>"
 $tableEntry += "<td bgcolor='#387C44' align=center>$howOldBkp</td>"
}
else
{
 $tableEntry += "<td bgcolor='#FF0000' align=center>$lastbackup</td>"
 $tableEntry += "<td bgcolor='#FF0000' align=center>$howOldBkp</td>"
}
Add-Content $fileName $tableEntry
Write-Host $tableEntry
}


writehtmlheader $fileName
writetableheader $fileName
get-DBInfo
writehtmlfooter $fileName

