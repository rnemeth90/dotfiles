#Requires –Version 3.0
################################
#       Adamj Clean-WSUS       #
#         Version 2.07         #
#                              #
#   The last WSUS Script you   #
#       will ever need!        #
#                              #
#  Taken from various sources  #
#      from the Internet.      #
#                              #
#  Modified By: Adam Marshall  #
#     http://www.adamj.org     #
################################

<#
################################
#         Prerequisites       #
################################

1. This script has to be saved as plain text in ANSI format. If you use Notepad++, you must
   change the encoding to ANSI (Encoding > 'Encode in ANSI' or Encode > 'Convert to ANSI').
   An easy way to tell if it is saved in plain text (ANSI) format is that there is a #Requires
   statement at the top of the script. Make sure that there is a hyphen before the word
   "Version" and you shouldn't have a problem with executing it. If you end up with an error
   like below, it is due to the encoding of the file as you can tell by the â€“ characters
   before the word Version.

   At C:\Scripts\Clean-WSUS.ps1:1 char:13
   + #Requires â€“Version 3.0

2. You must run this on the WSUS Server itself and any downstream WSUS servers you may have.

3. On the WSUS Server, you must install the SQL Server Management Studio (SSMS) from Microsoft
   so that you have the SQLCMD utility.

4. You must have Powershell 3.0 or higher installed. I recommend version 4.0 or higher.

    - For Server 2008 SP2:
        - Install Windows Powershell from Server Manager - Features
        - Install .NET 3.5 SP1 from - https://www.microsoft.com/en-ca/download/details.aspx?id=25150
        - Install SQL Server Management Studio from https://www.microsoft.com/en-ca/download/details.aspx?id=30438
          You want to choose SQLManagementStudio_x64_ENU.exe
        - Install .NET 4.0 - https://www.microsoft.com/en-us/download/details.aspx?id=17718
        - Install Powershell 2.0 & WinRM 2.0 from https://www.microsoft.com/en-ca/download/details.aspx?id=20430
        - Install Windows Management Framework 3.0 from https://www.microsoft.com/en-us/download/confirmation.aspx?id=34595

    - For Server 2008 R2:
        - Install .NET 4.5.2 from https://www.microsoft.com/en-ca/download/details.aspx?id=42642
        - Install Windows Management Framework 4.0 and reboot from https://www.microsoft.com/en-ca/download/details.aspx?id=40855
        - Install SQL Server Management Studio from https://www.microsoft.com/en-ca/download/details.aspx?id=30438
          You want to choose SQLManagementStudio_x64_ENU.exe

    - For Server 2012 & 2012 R2
        - Install SQL Server Management Studio from https://www.microsoft.com/en-us/download/details.aspx?id=29062
          You want to choose the ENU\x64\SQLManagementStudio_x64_ENU.exe

################################
#         Instructions         #
################################


 1. Edit the variables below to match your environment.
 2. Open PowerShell using "Run As Administrator" on the WSUS Server.
 3. Because you downloaded this script from the internet, you cannot initially run it directly
    as the ExecutionPolicy is default set to "Restricted" (Server 2008, Server 2008 R2, and
    Server 2012) or "RemoteSigned" (Server 2012 R2).  You must change your ExecutionPolicy to
    Bypass. You can do this with Set-ExecutionPolicy, however that will change it globally for
    the server, which is not recommended. Instead, launch another PowerShell.exe with the
    ExecutionPolicy set to bypass for just that session. At your current PowerShell prompt,
    type in: "PowerShell.exe -ExecutionPolicy Bypass" and press enter.
 3. Run the script using -FirstRun. (e.g. ".\Clean-WSUS.ps1 -FirstRun")
 4. Create a Scheduled Task to run Clean-WSUS.ps1 -ScheduledRun, daily at the time you wish.
    I recommend running it at 8:00 AM.

To Create a Scheduled Task:

 1. Open Task Scheduler and Create a new task (not a basic task)
 2. Go to the General Tab:
 3. Name: "Adamj Clean-WSUS"
 4. Under the section "Security Options" put the dot in "Run whether the user is logged on or not"
 5. Check "Do not store password. The task will only have access to local computer resources"
 6. Check "Run with highest privileges."
 7. Under the section "Configure for" - Choose the OS of the Server (e.g. Server 2012 R2)
 8. Go to the Triggers Tab:
 9. Click New at the bottom left.
10. Under the section "Settings"
11. Choose Daily. Pick a time to run (e.g. 8:00 AM)
12. Confirm Enabled is checked, Press OK.
13. Go to the Actions Tab:
14. Click New at the bottom left.
15. Action should be "Start a program"
16. The "Program/script" should be set to the path to PowerShell on that server.
    (e.g: %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe)
17. The arguments line should have "-ExecutionPolicy Bypass " and then the path to this script and
    the -ScheduledRun switch.
    (e.g: -ExecutionPolicy Bypass "C:\Scripts\Clean-WSUS.ps1 -ScheduledRun")
18. Go to the Settings Tab:
19. Check "Allow task to be run on demand"
20. Click OK
#>

# You can use Get-Help .\Clean-WSUS for more information.

<#
.SYNOPSIS
This is the last WSUS Script you will ever need. It has the capacity to remove all drivers from the database, remove declined updates, decline superseded updates, run the SQL database maintenance, remove synchronization logs, and finally run the server cleanup wizard.


.DESCRIPTION
################################
#    Background Information    #
#          on Streams          #
################################

All my recommendations are set in -ScheduledRun.

Adamj Remove WSUS Drivers Stream
-----------------------------------------------------

This stream will remove all WSUS Drivers Classifications from the WSUS database.
This has 2 possible running methods - Run through PowerShell, or Run directly in SQL.
The -FirstRun Switch will force the SQL method, but all other automatic runs will use the
PowerShell method. I recommend this be done every quarter.

You can use -RemoveWSUSDriversSQL or -RemoveWSUSDriversPS to run these manually from the command-line.

Adamj Remove Declined WSUS Updates Stream
-----------------------------------------------------

This stream will remove any Declined WSUS updates from the WSUS Database. This is good if you are removing
Specific products (Like Server 2003 / Windows XP updates) from the WSUS server under the Products and
Classifications section. Since this will remove them from the database, if they are still valid,
the next synchronizations will pick up the updates again. I recommend that this be done every quarter.

You can use -RemoveDeclinedWSUSUpdates to run this manually from the command-line.

Adamj WSUS Database Maintenance Stream
-----------------------------------------------------

This stream will perform basic maintenance tasks on SUSDB, the WSUS Database. It will identify indexes
that are fragmented and defragment them. For certain tables, a fill-factor is set in order to improve
insert performance. It will then update potentially out-of-date table statistics. I recommend that this
be done daily.

You can use -WSUSDBMaintenance to run this manually from the command-line.

Adamj Decline Superseded Updates Stream
-----------------------------------------------------

This stream will decline any update that is superseded and not yet declined. This is a BONUS cleanup for
shrinking down the size of your WSUS Server. Any update that has been superseded but has not been declined
is using extra space. This will save you GB of data in your WsusContent folder. I recommend that this be
done every month.

You can use -DeclineSupersededUpdates to run this manually from the command-line.

### Please read the background information below for more details. ###

The Server Cleanup Wizard (SCW) declines superseded updates, only if:

    The newest update is approved, and
    The superseded updates are Not Approved, and
    The superseded update has not been reported as NotInstalled (i.e. Needed) by any computer in the previous 30 days. 

There is no feature in the product to automatically decline superseded updates on approval of the newer update,
and in fact, you really do not want that feature. The "Best Practice" in dealing with this situation is:

1. Approve the newer update.
2. Verify that all systems have installed the newer update.
3. Verify that all systems now report the superseded update as Not Applicable.
4. THEN it is safe to decline the superseded update.

To SEARCH for superseded updates, you need only enable the Superseded flag column in the All Updates view, and sort on that column.

There will be four groups:

1. Updates which have never been superseded (blank icon).
2. Updates which have been superseded, but have never superseded another update (icon with blue square at bottom).
3. Updates which have been superseded and have superseded another update (icon with blue square in middle).
4. Updates which have superseded another update (icon with blue square at top).

There's no way to filter based on the approval status of the updates in group #4, but if you've verified that all
necessary/applicable updates in group #4 are approved and installed, then you'd be free to decline groups #2 and #3 en masse.

If you decline superseded updates using the method described:

1. Approve the newer update.
2. Verify that all systems have installed the newer update.
3. Verify that all systems now report the superseded update as Not Applicable.
4. THEN it is safe to decline the superseded update.

### THIS SCRIPT DOES NOT FOLLOW THE ABOVE GUIDELINES. IT WILL JUST DECLINE ANY SUPERSEDED UPDATES. ###

Adamj Clean Up WSUS Synchronization Logs Stream
-----------------------------------------------------

This stream will remove all synchronization logs beyond a specified time period. WSUS is lacking the ability
to remove synchronization logs through the GUI. Your WSUS server will become slower and slower loading up
the synchronization logs view as the synchronization logs will just keep piling up over time. If you have
your synchronization settings set to synchronize 4 times a day, it would take less than 3 months before you
have over 300 logs that it has to load for the view. This is very time consuming and many just ignore this
view and rarely go to it. When they accidentally click on it, they curse. I recommend that this be done daily.

You can use -CleanUpWSUSSynchronizationLogs to run this manually from the command-line.


Adamj Server Cleanup Wizard Stream
-----------------------------------------------------

The Server Cleanup Wizard (SCW) is integrated into the WSUS GUI, and can be used to help you manage your
disk space. This runs the SCW through PowerShell which has the added bonus of not timing out as often
the SCW GUI would.

This wizard can do the following things:
    - Remove unused updates and update revisions 
      The wizard will remove all older updates and update revisions that have not been approved.

    - Delete computers not contacting the server
      The wizard will delete all client computers that have not contacted the server in thirty days or more.

    - Delete unneeded update files
      The wizard will delete all update files that are not needed by updates or by downstream servers.

    - Decline expired updates
      The wizard will decline all updates that have been expired by Microsoft.

    - Decline superseded updates
      The wizard will decline all updates that meet all the following criteria:
          The superseded update is not mandatory
          The superseded update has been on the server for thirty days or more
          The superseded update is not currently reported as needed by any client
          The superseded update has not been explicitly deployed to a computer group for ninety days or more
          The superseding update must be approved for install to a computer group

I recommend that this be done daily.

You can use -WSUSServerCleanupWizard to run this manually from the command-line.

.NOTES
Name: Clean-WSUS
Author: Adam Marshall
Website: http://www.adamj.org

This script has been tested on Server 2008 SP2, Server 2008 R2, Server 2012, and Server 2012 R2.

################################
#      Version History &       #
#        Release Notes         #
################################

 Version 1.0 to 1.1
 - Added "Diskspace Freed (GB)" from example code https://p0w3rsh3ll.wordpress.com/2015/01/26/cleanup-wsus/
 - Re-formatted output of the email.
 
 Version 1.1 to 1.2
 - Created the Adamj Bonus Cleanup Stream. Changed the output email into HTML and formatted the output nicely.
 - Thanks to Rob Dunn from the Spiceworks forums for reviewing the code and making some suggestions on the
   code to help enumerate information better.

 Version 1.2 to 1.3
 - Added the $AdamjBonusCleanupUpdatesCount variable to the output line on the declining updates message, so that
   a copy/paste can easily be done that shows how many updates were declined when it actually declines them.

 Version 1.3 to 1.5
 - Added the Adamj Remove Drivers Stream, Adamj Remove Declined WSUS Updates Stream, and the Adamj WSUS DB
   Maintenance Stream. Renamed the Adamj Bonus Cleanup Stream to Adamj Decline Superseded Updates Stream. 
 - Changed the formulation of the script into modular form. Now the script has 5 modular streams:
   1. WSUS Server Cleanup Wizard Stream
   2. Adamj Remove WSUS Drivers Stream
   3. Adamj Remove Declined WSUS Updates Stream
   4. Adamj WSUS 3.0 DB Maintenance Stream
   5. Adamj Decline Superseded Updates Stream.
 
 Version 1.5 to 2.01
 - Changed the mail function to allow for authentication, SSL, and SMTP Port
 - Cleaned up the 'Clean Up Variables' section to account for all Adamj* Variables
 - Added Clean Up WSUS Synchronization Logs Stream to keep the Sync logs clean
 - Added SQL Auto-detect with function help from
   (http://stackoverflow.com/questions/11540445/how-to-verify-whether-the-sql-server-instance-is-correct-or-not-using-powershell)
 - Redesigned pretty much the entire script into a function driven script.
 - Added cmdlet options for running each section manually, or by way of the recommended time periods (Daily, Monthly, Quarterly)
 - Added error checking and throwing better error messages on various things.
 - Added Test-Administrator to confirm it is being run with elevated rights.
 - Updated the Prerequisites and Instructions sections.
 - Updated the output of the SCW.

 Version 2.00 to 2.01
 - Troubleshooting help by Malil from Spiceworks forums which lead to 2 small but significant code changes
   for the auto-detection of the $AdamjSQLServer variable, provided by Malil.
 - Fixed the SCW to also account for hours run, rather than just minutes and seconds.

 Version 2.01 to 2.02
 - Malil helped troubleshooting further and I made code changes for $AdamjSQLServer on Server 2008.
 - Added better email logs for the RemoveWSUSDriversSQL Stream. Added console messages to show that the script is still working
   and what it is doing as this stream will take time. Added console error message summaries, and file/email error message
   details.
 - Changed Quarterly months defaults to 1, 4, 7, 10.

 Version 2.02 to 2.03
 - Properly formatted running time duration to hh:mm:ss
 - Added calculated duration of each stream, and total script duration.
 - Removed a duplicated value in the setup configuration

 Version 2.03 to 2.04
 - Fixed issue with SQL Connection command for issues with connecting to a Windows Server 2008 Internal Database.
 - Fixed some visual issues with the TXT output relating to the duration..
 - Clarified some instructional text at the top.

 Version 2.04 to 2.05
 - Tested on Server 2008 SP2, Server 2008 R2, Server 2012, and Server 2012 R2.
 - Came up with installation instructions for prerequisites.
 - Added code for detecting last day of the month if $AdamjScheduledRunStreamsDay
   is greater than the last day of the month, including leap years for months less than 31 days.
 - Thank you to Malil for the initial base of the code for checking for $AdamjScheduledRunStreamsDay

 Version 2.05 to 2.06
 - Added notes regarding a Remote SQL connection such that you must use the computer account to run the script
   via Schedule Tasks.
 - Added a -HelpMe Stream for getting troubleshooting data for support reasons.
 - Check for for replica server and exclude only the DeclineSupersededUpdates as you can only decline superseded updates
   from the upstream server. Thanks to Jurriaan van Doornik for the help with testing and investigating.
 - Adjusted the Timeout on the SQL-Ping Function to 60 seconds only if you specify the $AdamjSQLServer variable.
 - Altered the Versioning notes layout for clarity and separation.
 - Added a prerequisite of ANSI encoding for troubleshooting.
 - Adjusted some of the descriptions of the streams information text to be more clear and consistent.
 - Spelling and grammar fixes.

 Version 2.06 to 2.07
 - Adjusted the prerequisites wording for clarity regarding the ANSI encoding.

.EXAMPLE
Clean-WSUS -FirstRun
Description: Run the routines that are recommended for running this script for the first time.
.EXAMPLE
Clean-WSUS -HelpMe
Description: Run the troubleshooting HelpMe stream to copy and paste from the console window for getting support.
.EXAMPLE
Clean-WSUS -DailyRun
Description: Run the recommended daily routines.
.EXAMPLE
Clean-WSUS -MonthlyRun
Description: Run the recommended monthly routines.
.EXAMPLE
Clean-WSUS -QuarterlyRun
Description: Run the recommended quarterly routines.
.EXAMPLE
Clean-WSUS -ScheduledRun
Description: Run the recommended routines on a schedule having the script take care of all timetables.
.EXAMPLE
Clean-WSUS -RemoveWSUSDriversSQL -SaveReport "TXT"
Description: Only Remove WSUS Drivers by way of SQL and save the output as TXT to the script's folder
             named with the date and time of execution.
.EXAMPLE
Clean-WSUS -RemoveWSUSDriversPS -MailReport "HTML"
Description: Only Remove WSUS Drivers by way of PowerShell and email the output as HTML to the
             configured parties.
.EXAMPLE
Clean-WSUS -RemoveDeclinedWSUSUpdates -CleanUpWSUSSynchronizationLogs -WSUSDBMaintenance -WSUSServerCleanupWizard -SaveReport "HTML" -MailReport "TXT"
Description: Remove Declined WSUS Updates, Clean Up WSUS Synchronization Logs based on the configuration
             variables, Run the SQL Maintenance, and run the Server Cleanup Wizard (SCW) and output to
             an HTML file in the scripts folder named with the date and time of execution, and then
             email the report in plain text to the configured parties.
.EXAMPLE
Clean-WSUS -DeclineSupersededUpdates -SaveReport "TXT" -MailReport "HTML"
Description: Decline superseded updates, save the output as TXT to the script's folder, and email the
             output as HTML to the configured parties.

.LINK
http://www.adamj.org
http://community.spiceworks.com/scripts/show/2998-adamj-wsus-cleanup

#>

################################
#    Script Setup Parameters   #
#                              #
#  DO NOT EDIT!!! SCROLL DOWN  #
#    TO FIND THE VARIABLES     #
#           TO EDIT            #
################################

[cmdletbinding()]
param (
    # Run the recommended daily routines.
    [Switch]$DailyRun,
     # Run the routines that are recommended for running this script for the first time.
    [Switch]$FirstRun,
    # Run the recommended monthly routines.
    [Switch]$MonthlyRun,
    # Run the recommended quarterly routines.
    [Switch]$QuarterlyRun,
    # Run the recommended routines on a schedule having the script take care of all timetables.
    [Switch]$ScheduledRun,
    # Remove WSUS Drivers by way of SQL.
    [Switch]$RemoveWSUSDriversSQL,
    # Remove WSUS Drivers by way of PowerShell.
    [Switch]$RemoveWSUSDriversPS,
    # Remove Declined WSUS Updates.
    [Switch]$RemoveDeclinedWSUSUpdates,
    # Run the SQL Maintenance.
    [Switch]$WSUSDBMaintenance,
    # Decline Superseded Updates.
    [Switch]$DeclineSupersededUpdates,
    # Clean Up WSUS Synchronization Logs based on the configuration variables.
    [Switch]$CleanUpWSUSSynchronizationLogs,
    # Run the Server Cleanup Wizard (SCW) through PowerShell rather than through a GUI.
    [Switch]$WSUSServerCleanupWizard,
    # Save the output report to a file named the date and time of execute in the script's folder. TXT or HTML are valid output types.
    [String]$SaveReport,
    # Email the output report to an email address based on the configuration variables. TXT or HTML are valid output types.
    [String]$MailReport,
    # Run the troubleshooting HelpMe stream to copy and paste for getting support.
    [Switch]$HelpMe
    )
if (($DailyRun -eq $False -and $FirstRun -eq $False -and $MonthlyRun -eq $False -and $QuarterlyRun -eq $False -and $ScheduledRun -eq $False -and $HelpMe -eq $False) -and ($SaveReport -eq '' -and $MailReport -eq '')) { Throw "You must use -SaveReport or -MailReport if you are not going to use -FirstRun, -DailyRun, -MonthlyRun, -QuarterlyRun, or -ScheduledRun" }
if ($SaveReport -ne '' -and ($SaveReport -NotIn "HTML","TXT")) { Throw "You must use either HTML or TXT with -SaveReport. You set it as: $SaveReport" }
if ($MailReport -ne '' -and ($MailReport -NotIn "HTML","TXT")) { Throw "You must use either HTML or TXT with -MailReport. You set it as: $SaveReport" }

################################
#     WSUS Setup Variables     #
################################

# Enter your FQDN of the WSUS server. Example: "server.domain.local"
[string]$AdamjWSUSServer = "sbdwusi01.corp.vibehcm.com"

# Use secure connection: $True or $False
[boolean]$AdamjWSUSServerUseSecureConnection = $False

# What port number are you using for WSUS? Example: "80" or "443" if on Server 2008 or "8530" or "8531" if on Server 2012+
[int32]$AdamjWSUSServerPortNumber = "8530"

################################
#  Mail Report Setup Variables #
################################

# From: address for email notifications (it doesn't have to be a real email address). Example: "WSUS@domain.com"
[string]$AdamjMailReportEmailFromAddress = "wsus@vibehcm.com"

# To: address for email notifications. Example: "firstname.lastname@domain.com"
[string]$AdamjMailReportEmailToAddress = "it_services@vibehcm.com"

# Subject: of the results email
[string]$AdamjMailReportEmailSubject = "SBDWUSI01.CORP.VIBEHCM.COM - WSUS Cleanup Results"

# Enter your SMTP server name. Example: "mailserver.domain.local" or "mail.domain.com" or "smtp.gmail.com"
[string]$AdamjMailReportSMTPServer = "relay.vibehcm.com"

# Enter your SMTP port number. Example: "25" or "465" (Usually for SSL) or "587" or "1025"
[int32]$AdamjMailReportSMTPPort = "25"

# Do you want to enable SSL communication for your SMTP Server
[boolean]$AdamjMailReportSMTPServerEnableSSL = $False

# Do you need to authenticate to the server? If not, leave blank.
[string]$AdamjMailReportSMTPServerUsername = ""
[string]$AdamjMailReportSMTPServerPassword = ""

################################
#  WSUS Server Cleanup Wizard  #
#          Parameters          #
#    Set to $True or $False    #
################################

# Decline updates that have not been approved for 30 days or more, are not currently needed by any clients, and are superseded by an approved update.
[boolean]$AdamjSCWSupersededUpdatesDeclined = $True

# Decline updates that aren't approved and have been expired my Microsoft.
[boolean]$AdamjSCWExpiredUpdatesDeclined = $True

# Delete updates that are expired and have not been approved for 30 days or more.
[boolean]$AdamjSCWObsoleteUpdatesDeleted = $True

# Delete older update revisions that have not been approved for 30 days or more.
[boolean]$AdamjSCWUpdatesCompressed = $True

# Delete computers that have not contacted the server in 30 days or more.
[boolean]$AdamjSCWObsoleteComputersDeleted = $True

# Delete update files that aren't needed by updates or downstream servers.
[boolean]$AdamjSCWUnneededContentFiles = $True

################################
#   Scheduled Run Variables    #
################################

# On what day do you wish to run the MonthlyRun and QuarterlyRun Stream? I recommend on the 1st-7th of the month.
# This will give enough time for you to approve (if you approve manually) and your computers to receive the
# superseding updates after patch Tuesday (second Tuesday of the month).
# (Valid days are 1-31. February, April, June, September, and November have logic to set to the last day
# of the month if this is set to a number greater than the amount of days in that month, including leap years.)
[int]$AdamjScheduledRunStreamsDay = "1"

# What months would you like to run the QuarterlyRun Stream?
# (Valid months are 1-12, comma separated for multiple months)
[string]$AdamjScheduledRunQuarterlyMonths = "1,4,7,10"

################################
#        Clean Up WSUS         #
#     Synchronization Logs     #
#           Variables          #
################################

# Clean up the synchronization logs older than a consistency.

# (Valid consistency number are whole numbers.)
[int]$AdamjCleanUpWSUSSynchronizationLogsConsistencyNumber = "14"

# Valid consistency time are "Day" or "Month"
[String]$AdamjCleanUpWSUSSynchronizationLogsConsistencyTime = "Day"

# Or remove all synchronization logs each time
[boolean]$AdamjCleanUpWSUSSynchronizationLogsAll = $False

################################
#     SQL Server Variable      #
################################

# ONLY uncomment and fill out if you are using a dedicated SQL Instance or if the script tells you to
# otherwise leave this commented for auto-detection of the proper SQL Instance for the Windows Internal Database.
# Example: "SERVER\INSTANCE" or "SERVER" (if using the Default Instance)

# If you are using a Remote SQL connection, you will need to set the Scheduled Task to use the computer account
# as the user that runs the script (Instead of searching for it, you must type it in the format of: DOMAIN\COMPUTER$)
# or run the Scheduled Task as a user account saving credentials so that it can pass them through to the SQL Server.

#[string]$AdamjSQLServer = ""

################################
# Do not edit below this line  #
################################
$AdamjScriptTime = Get-Date

# Set the script's current working directory path
$AdamjScriptPath = split-path -parent $MyInvocation.MyCommand.Definition

function Test-Administrator  
{  
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $CurrentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}
$AdamjTestAdministrator = Test-Administrator
if ($AdamjTestAdministrator -eq $True) { }
if ($AdamjTestAdministrator -eq $False) {
    Write-Host "You must run this from an Elevated PowerShell Prompt on each WSUS Server in your environment. If this is done through scheduled tasks, you must check the box `"Run with the highest privileges`""
    Throw "You must run this from an Elevated PowerShell Prompt on each WSUS Server in your environment. If this is done through scheduled tasks, you must check the box `"Run with the highest privileges`""
}

if ($HelpMe -eq $True) {
    Write-Host ""
    Write-Host "============================="
    Write-Host "Clean-WSUS HelpMe Stream"
    Write-Host "============================="
    Write-Host ""
    Write-Host "This is the HelpMe Section for troubleshooting"
    Write-Host "Please provide this information to get support"
    Write-Host ""
    Write-Host ""
    Write-Host ""
}

function SQL-Ping-Instance 
{
    param (
        [parameter(Mandatory = $true)][string] $ServerInstance,
        [parameter(Mandatory = $false)][int] $TimeOut = 1
    )

    $PingResult = $false

    try
    {
        $SqlCatalog = "master"
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server = $ServerInstance; Database = $SqlCatalog; Integrated Security = True; Connection Timeout=$TimeOut"
        $TimeOutVerbage = if ($TimeOut -gt "1") { "seconds" } else { "second" }
        Write-Host "Initiating SQL Connection Testing to $ServerInstance with a timeout of $TimeOut $TimeOutVerbage" 
        $SqlConnection.Open() 
        $PingResult = $SqlConnection.State -eq "Open"
    }

    catch
    {
        Write-Host "Connection Failed."
    }

    finally
    {
        $SqlConnection.Close()
    }

    return $pingResult
}

[string]$AdamjWID2008 = 'np:\\.\pipe\MSSQL$MICROSOFT##SSEE\sql\query'
[string]$AdamjWID2012 = 'np:\\.\pipe\MICROSOFT##WID\tsql\query'
if (-not [string]::isnullorempty($AdamJSQLServer)) {
    # Test to see if $AdamjSQLServer is set and if it is, with something other than blank.
    # Then test to see if it can connect.
    if ((SQL-Ping-Instance $AdamjSQLServer 60) -eq $False) {
        # If it doesn't work, terminate the script erroring out with a reason.
        Write-Host "I've tested the server `"$AdamjSQLServer`" in the configuration but can't connect to that SQL Server Instance. Please check the spelling again. Don't forget to specify the SQL Instance if there is one."
        Throw "I've tested the server `"$AdamjSQLServer`" in the configuration but can't connect to that SQL Server Instance. Please check the spelling again. Don't forget to specify the SQL Instance if there is one."
        }
} elseif ((SQL-Ping-Instance $AdamjWID2008) -eq $true) {
    # For server 2008 & 2008 R2 Windows Internal Database
    $AdamjSQLServer = $AdamjWID2008
} elseif ((SQL-Ping-Instance $AdamjWID2012) -eq $true) {
    # For server 2012 & 2012 R2 Windows Internal Database
    $AdamjSQLServer = $AdamjWID2012
} else {
    if ($HelpMe -ne $True) {
        #Terminate the script erroring out with a reason.
        Write-Host "I can't determine the SQL Server Instance. Please find the `"`$AdamjSQLServer`" variable in the configuration and set it as your SERVER\INSTANCE for WSUS"
        Throw "I can't determine the SQL Server Instance. Please find the `"`$AdamjSQLServer`" variable in the configuration and set it as your SERVER\INSTANCE for WSUS"
    }
    else { Write-Host "I can't connect to SQL, and you've asked for help. Connecting to the WSUS Server to get troubleshooting information." }
}

#Create the connection command variable.
$AdamjSQLConnectCommand = "sqlcmd -S $AdamjSQLServer"

# Load .NET assembly
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration");

# Connect to WSUS Server
$AdamjWSUSServerAdminProxy = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($AdamjWSUSServer,$AdamjWSUSServerUseSecureConnection,$AdamjWSUSServerPortNumber);
If ($? -eq $False) { 
    Write-Host "ERROR Connecting to the WSUS Server: $AdamjWSUSServer. Please check your settings and try again."
    Throw "ERROR Connecting to the WSUS Server: $AdamjWSUSServer. Please check your settings and try again."
} else {
        $AdamjConnectedTime = Get-Date
        $AdamjConnectedTXT = "Connected to the WSUS server $AdamjWSUSServer @ $($AdamjConnectedTime.ToString(`"yyyy.MM.dd hh:mm:ss tt zzz`"))`r`n`r`n"
        $AdamjConnectedHTML = "<i>Connected to the WSUS server $AdamjWSUSServer @ $($AdamjConnectedTime.ToString(`"yyyy.MM.dd hh:mm:ss tt zzz`"))</i>`r`n`r`n"
    	Write-Host "Connected to the WSUS server $AdamjWSUSServer"
}

################################
#         Get-DiskFree         #
################################

function Get-DiskFree
# Taken from http://binarynature.blogspot.ca/2010/04/powershell-version-of-df-command.html
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias('hostname')]
        [Alias('cn')]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        
        [Parameter(Position=1,
                   Mandatory=$false)]
        [Alias('runas')]
        [System.Management.Automation.Credential()]$Credential =
        [System.Management.Automation.PSCredential]::Empty,
        
        [Parameter(Position=2)]
        [switch]$Format
    )
    
    BEGIN
    {
        function Format-HumanReadable 
        {
            param ($size)
            switch ($size) 
            {
                {$_ -ge 1PB}{"{0:#.#'P'}" -f ($size / 1PB); break}
                {$_ -ge 1TB}{"{0:#.#'T'}" -f ($size / 1TB); break}
                {$_ -ge 1GB}{"{0:#.#'G'}" -f ($size / 1GB); break}
                {$_ -ge 1MB}{"{0:#.#'M'}" -f ($size / 1MB); break}
                {$_ -ge 1KB}{"{0:#'K'}" -f ($size / 1KB); break}
                default {"{0}" -f ($size) + "B"}
            }
        }
        
        $wmiq = 'SELECT * FROM Win32_LogicalDisk WHERE Size != Null AND DriveType >= 2'
    }
    
    PROCESS
    {
        foreach ($computer in $ComputerName)
        {
            try
            {
                if ($computer -eq $env:COMPUTERNAME)
                {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -ErrorAction Stop
                }
                else
                {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -Credential $Credential `
                             -ErrorAction Stop
                }
                
                if ($Format)
                {
                    # Create array for $disk objects and then populate
                    $diskarray = @()
                    $disks | ForEach-Object { $diskarray += $_ }
                    
                    $diskarray | Select-Object @{n='Name';e={$_.SystemName}}, 
                        @{n='Vol';e={$_.DeviceID}},
                        @{n='Size';e={Format-HumanReadable $_.Size}},
                        @{n='Used';e={Format-HumanReadable `
                        (($_.Size)-($_.FreeSpace))}},
                        @{n='Avail';e={Format-HumanReadable $_.FreeSpace}},
                        @{n='Use%';e={[int](((($_.Size)-($_.FreeSpace))`
                        /($_.Size) * 100))}},
                        @{n='FS';e={$_.FileSystem}},
                        @{n='Type';e={$_.Description}}
                }
                else 
                {
                    foreach ($disk in $disks)
                    {
                        $diskprops = @{'Volume'=$disk.DeviceID;
                                   'Size'=$disk.Size;
                                   'Used'=($disk.Size - $disk.FreeSpace);
                                   'Available'=$disk.FreeSpace;
                                   'FileSystem'=$disk.FileSystem;
                                   'Type'=$disk.Description
                                   'Computer'=$disk.SystemName;}
                    
                        # Create custom PS object and apply type
                        $diskobj = New-Object -TypeName PSObject `
                                   -Property $diskprops
                        $diskobj.PSObject.TypeNames.Insert(0,'BinaryNature.DiskFree')
                    
                        Write-Output $diskobj
                    }
                }
            }
            catch 
            {
                # Check for common DCOM errors and display "friendly" output
                switch ($_)
                {
                    { $_.Exception.ErrorCode -eq 0x800706ba } `
                        { $err = 'Unavailable (Host Offline or Firewall)'; 
                            break; }
                    { $_.CategoryInfo.Reason -eq 'UnauthorizedAccessException' } `
                        { $err = 'Access denied (Check User Permissions)'; 
                            break; }
                    default { $err = $_.Exception.Message }
                }
                Write-Warning "$computer - $err"
            } 
        }
    }
    
    END {}
}

################################
#       Setup the Header       #
################################

function CreateAdamjHeader {
$Script:AdamjBodyHeaderTXT = @"
################################ 
#                              #
#       Adamj Clean-WSUS       #
#         Version 2.07         #
#                              #
#   The last WSUS Script you   #
#        will ever need!       #
#                              #
################################


"@
$Script:AdamjBodyHeaderHTML = @"
    <table style="height: 0px; width: 0px;" border="0">
	    <tbody>
		    <tr>
			    <td colspan="3">
				    <span
						    style="font-family: tahoma,arial,helvetica,sans-serif;">################################</span>
			    </td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td style="text-align: center;">&nbsp;</td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">Adamj Clean-WSUS</span></td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">Version 2.07</span></td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td>&nbsp;</td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">The last WSUS Script you</span></td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">will ever need!</span></td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td>&nbsp;</td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td colspan="3"><span style="font-family: tahoma,arial,helvetica,sans-serif;">################################</span></td>
		    </tr>
	    </tbody>
    </table>


"@
}


################################
#       Setup the Footer       #
################################

function CreateAdamjFooter {

$Script:AdamjBodyFooterTXT = @"

################################ 
#    End of the WSUS Cleanup   #
################################
#                              #
#         Adam Marshall        #
#     http://www.adamj.org     #
#                              #
#   Latest version available   #
#        from Spiceworks       #
#                              #
################################

http://community.spiceworks.com/scripts/show/2998-adamj-clean-wsus
"@
$Script:AdamjBodyFooterHTML = @"
    <table style="height: 0px; width: 0px;" border="0">
      <tbody>
        <tr>
          <td colspan="3"><span style="font-family: tahoma,arial,helvetica,sans-serif;">################################</span></td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">End of the WSUS Cleanup</span></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td colspan="3" rowspan="1"><span style="font-family: tahoma,arial,helvetica,sans-serif;">################################</span></td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;">&nbsp;</td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">Adam Marshall</span></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">http://www.adamj.org</span></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td>&nbsp;</td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">Latest version available</span></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><a href="http://community.spiceworks.com/scripts/show/2998-adamj-clean-wsus"><span style="font-family: tahoma,arial,helvetica,sans-serif;">from Spiceworks</span></a></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td>&nbsp;</td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td colspan="3"><span style="font-family: tahoma,arial,helvetica,sans-serif;">################################</span></td>
        </tr>
      </tbody>
    </table>
"@
}

################################
#   Adamj Remove WSUS Drivers  #
#           Stream             #
################################

function RemoveWSUSDrivers {
    param (
        [Parameter()]
        [Switch] $SQL
    )
    function RemoveWSUSDriversSQL {
        $AdamjRemoveWSUSDriversSQLScript = @"
/*
################################
#   Adamj WSUS Delete Drivers  #
#         SQL Script           #
#       Version 1.0            #
#  Taken from various sources  #
#      from the Internet.      #
#                              #
#  Modified By: Adam Marshall  #
#     http://www.adamj.org     #
################################

-- Originally taken from http://www.flexecom.com/how-to-delete-driver-updates-from-wsus-3-0/
-- Modified to be dynamic and more of a nice output
*/
USE SUSDB;
GO

SET NOCOUNT ON;
DECLARE @tbrevisionlanguage nvarchar(255)
DECLARE @tbProperty nvarchar(255)
DECLARE @tbLocalizedPropertyForRevision nvarchar(255)
DECLARE @tbFileForRevision nvarchar(255)
DECLARE @tbInstalledUpdateSufficientForPrerequisite nvarchar(255)
DECLARE @tbPreRequisite nvarchar(255)
DECLARE @tbDeployment nvarchar(255)
DECLARE @tbXml nvarchar(255)
DECLARE @tbPreComputedLocalizedProperty nvarchar(255)
DECLARE @tbDriver nvarchar(255)
DECLARE @tbFlattenedRevisionInCategory nvarchar(255)
DECLARE @tbRevisionInCategory nvarchar(255)
DECLARE @tbMoreInfoURLForRevision nvarchar(255)
DECLARE @tbRevision nvarchar(255)
DECLARE @tbUpdateSummaryForAllComputers nvarchar(255)
DECLARE @tbUpdate nvarchar(255)



DECLARE @var1 nvarchar(255)

/*
This query gives you the GUID that you will need to substitute in all subsequent queries. In my case, it is 
D2CB599A-FA9F-4AE9-B346-94AD54EE0629. I saw this GUID in several WSUS databases so I think it does not change;
at least not between WSUS 3.0 SP2 servers. Either way, we are setting a variable for this so this will
dynamically reference the correct GUID.
*/

SELECT @var1 = UpdateTypeID FROM tbUpdateType WHERE Name = 'Driver'

/*
The bad news is that WSUS database has over 100 tables. The good news is that SQL allows to enforce referential
integrity in data model designs, which in this case can be used to essentially reverse engineer a procedure,
that as far as I know isn’t documented anywhere.

The trick is to delete all driver type records from tbUpdate table – but FIRST we have to delete all records in
all other tables (revisions, languages, dependencies, files, reports…), which refer to driver rows in tbUpdate.

Here’s how this is done, in 16 tables/queries.
*/

delete from tbrevisionlanguage where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1)) 
SELECT @tbrevisionlanguage = @@ROWCOUNT
PRINT 'Delete records from tbrevisionlanguage: ' + @tbrevisionlanguage

delete from tbProperty where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbProperty = @@ROWCOUNT
PRINT 'Delete records from tbProperty: ' + @tbProperty

delete from tbLocalizedPropertyForRevision where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbLocalizedPropertyForRevision = @@ROWCOUNT
PRINT 'Delete records from tbLocalizedPropertyForRevision: ' + @tbLocalizedPropertyForRevision

delete from tbFileForRevision where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbFileForRevision = @@ROWCOUNT
PRINT 'Delete records from tbFileForRevision: ' + @tbFileForRevision

delete from tbInstalledUpdateSufficientForPrerequisite where prerequisiteid in (select Prerequisiteid from tbPreRequisite where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1)))
SELECT @tbInstalledUpdateSufficientForPrerequisite = @@ROWCOUNT
PRINT 'Delete records from tbInstalledUpdateSufficientForPrerequisite: ' + @tbInstalledUpdateSufficientForPrerequisite

delete from tbPreRequisite where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbPreRequisite = @@ROWCOUNT
PRINT 'Delete records from tbPreRequisite: ' + @tbPreRequisite

delete from tbDeployment where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbDeployment = @@ROWCOUNT
PRINT 'Delete records from tbDeployment: ' + @tbDeployment

delete from tbXml where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbXml = @@ROWCOUNT
PRINT 'Delete records from tbXml: ' + @tbXml

delete from tbPreComputedLocalizedProperty where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbPreComputedLocalizedProperty = @@ROWCOUNT
PRINT 'Delete records from tbPreComputedLocalizedProperty: ' + @tbPreComputedLocalizedProperty

delete from tbDriver where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbDriver = @@ROWCOUNT
PRINT 'Delete records from tbDriver: ' + @tbDriver

delete from tbFlattenedRevisionInCategory where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbFlattenedRevisionInCategory = @@ROWCOUNT
PRINT 'Delete records from tbFlattenedRevisionInCategory: ' + @tbFlattenedRevisionInCategory

delete from tbRevisionInCategory where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbRevisionInCategory = @@ROWCOUNT
PRINT 'Delete records from tbRevisionInCategory: ' + @tbRevisionInCategory

delete from tbMoreInfoURLForRevision where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbMoreInfoURLForRevision = @@ROWCOUNT
PRINT 'Delete records from tbMoreInfoURLForRevision: ' + @tbMoreInfoURLForRevision

delete from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1)
SELECT @tbRevision = @@ROWCOUNT
PRINT 'Delete records from tbRevision: ' + @tbRevision

delete from tbUpdateSummaryForAllComputers where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1)
SELECT @tbUpdateSummaryForAllComputers = @@ROWCOUNT
PRINT 'Delete records from tbUpdateSummaryForAllComputers: ' + @tbUpdateSummaryForAllComputers

PRINT CHAR(13)+CHAR(10) + 'This is the last query and this is really what we came here for.'

delete from tbUpdate where UpdateTypeID = @var1
SELECT @tbUpdate = @@ROWCOUNT
PRINT 'Delete records from tbUpdate: ' + @tbUpdate

/*
If at this point you get an error saying something about foreign key constraint, that will be most likely
due to the difference between which reports I ran in my WSUS installation and which reports were ran against
your particular installation. Fortunately, the error gives you exact location (table) where this constraint
is violated, so you can adjust one of the queries in the batch above to delete references in any other tables.
*/
"@

        # Create a file with the content of the AdamjRemoveWSUSDrivers SQL Script above in the
        # same working directory as this PowerShell script is running.

        $AdamjRemoveWSUSDriversSQLScriptFile = "$AdamjScriptPath\AdamjRemoveWSUSDrivers.sql"
        $AdamjRemoveWSUSDriversSQLScript | Out-File $AdamjRemoveWSUSDriversSQLScriptFile
        # Re-jig the $AdamjSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
        $AdamjSQLConnectCommand = $AdamjSQLConnectCommand.Replace('$','`$')
        # Execute the SQL Script and store the results in a variable.
        $AdamjRemoveWSUSDriversSQLScriptJobCommand = [scriptblock]::create("$AdamjSQLConnectCommand -i $AdamjRemoveWSUSDriversSQLScriptFile -I")
        $AdamjRemoveWSUSDriversSQLScriptJob = Start-Job -ScriptBlock $AdamjRemoveWSUSDriversSQLScriptJobCommand
        Wait-Job $AdamjRemoveWSUSDriversSQLScriptJob
        $AdamjRemoveWSUSDriversSQLScriptJobOutput = Receive-Job $AdamjRemoveWSUSDriversSQLScriptJob
        Remove-Job $AdamjRemoveWSUSDriversSQLScriptJob
        # Remove the SQL Script file.
        Remove-Item $AdamjRemoveWSUSDriversSQLScriptFile
        $Script:AdamjRemoveWSUSDriversSQLOutputTXT = $AdamjRemoveWSUSDriversSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n`r`n" 
        $Script:AdamjRemoveWSUSDriversSQLOutputHTML = $AdamjRemoveWSUSDriversSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","<br>`r`n" 
        
        # Variables Output
        # $AdamjRemoveWSUSDriversSQLOutputTXT
        # $AdamjRemoveWSUSDriversSQLOutputHTML

    }
    function RemoveWSUSDriversPS {
        $Count = 0
        $AdamjWSUSServerAdminProxy.GetUpdates() | Where-Object { $_.IsDeclined -eq $true -and $_.UpdateClassificationTitle -eq "Drivers" } | ForEach-Object {
            # Delete these updates
            $AdamjWSUSServerAdminProxy.DeleteUpdate($_.Id.UpdateId.ToString())
            $DeleteDeclinedDriverTitle = $_.Title
            $Count++
            $AdamjRemoveWSUSDriversPSDeleteOutputTXT += "$($Count). $($DeleteDeclinedDriverTitle)`n`n"
            $AdamjRemoveWSUSDriversPSDeleteOutputHTML += "<li>$DeleteDeclinedDriverTitle</li>`n"
        }
        $AdamjRemoveWSUSDriversPSDeleteOutputTXT += "`n`n"
        $AdamjRemoveWSUSDriversPSDeleteOutputHTML += "</ol>`n"

        $Script:AdamjRemoveWSUSDriversPSOutputTXT += "`n`n"
        $Script:AdamjRemoveWSUSDriversPSOutputHTML += "<ol>`n"
        $Script:AdamjRemoveWSUSDriversPSOutputTXT += $AdamjRemoveWSUSDriversPSDeleteOutputTXT
        $Script:AdamjRemoveWSUSDriversPSOutputHTML += $AdamjRemoveWSUSDriversPSDeleteOutputHTML

        # Variables Output
        # $AdamjRemoveWSUSDriversPSOutputTXT
        # $AdamjRemoveWSUSDriversPSOutputHTML
    }
    # Process the appropriate internal function
    $DateNow = Get-Date
    if ($SQL -eq $True) { RemoveWSUSDriversSQL } else { RemoveWSUSDriversPS }
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan –Start $DateNow –End $FinishedRunning
    # Create the output for the RemoveWSUSDrivers function
    $Script:AdamjRemoveWSUSDriversOutputTXT += "Adamj Remove WSUS Drivers:`n`n"
    $Script:AdamjRemoveWSUSDriversOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">Adamj Remove WSUS Drivers:</span></p>`n"
    if ($SQL -eq $True) { 
        $Script:AdamjRemoveWSUSDriversOutputTXT += $AdamjRemoveWSUSDriversSQLOutputTXT
        $Script:AdamjRemoveWSUSDriversOutputHTML += $AdamjRemoveWSUSDriversSQLOutputHTML
    } else {
        $Script:AdamjRemoveWSUSDriversOutputTXT += $AdamjRemoveWSUSDriversPSOutputTXT
        $Script:AdamjRemoveWSUSDriversOutputHTML += $AdamjRemoveWSUSDriversPSOutputHTML
    }
    $Script:AdamjRemoveWSUSDriversOutputTXT += "Remove WSUS Drivers Stream Duration: {0:00}:{1:00}:{2:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})
    $Script:AdamjRemoveWSUSDriversOutputHTML += "<p>Remove WSUS Drivers Stream Duration: {0:00}:{1:00}:{2:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $AdamjRemoveWSUSDriversOutputTXT
    # $AdamjRemoveWSUSDriversOutputHTML   
}

################################
#  Adamj Remove Declined WSUS  #
#       Updates Stream         #
################################

function RemoveDeclinedWSUSUpdates {
    param (
    [Switch]$Display,
    [Switch]$Proceed
    )

    # Log the date first
    $DateNow = Get-Date
    # Create an update scope
    $UpdateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
    # by default the update scope is created for any approval states
    $UpdateScope.ApprovedStates = "Any"
    # Get all updates that have been Superseded and not Declined
    $AdamjRemoveDeclinedWSUSUpdatesUpdates = $AdamjWSUSServerAdminProxy.GetUpdates($UpdateScope) | Where { ($_.isDeclined) }    
 
    function RemoveDeclinedWSUSUpdatesCountUpdates {
        # First count how many updates will be removed that are already declined updates - just for fun. I like fun :)
        $Script:AdamjRemoveDeclinedWSUSUpdatesCountUpdatesCount = "{0:N0}" -f $AdamjRemoveDeclinedWSUSUpdatesUpdates.Count
        $Script:AdamjRemoveDeclinedWSUSUpdatesCountUpdatesOutputTXT += "The number of declined updates that would be removed from the database are: $AdamjRemoveDeclinedWSUSUpdatesCountUpdatesCount.`r`n`r`n"
        $Script:AdamjRemoveDeclinedWSUSUpdatesCountUpdatesOutputHTML += "<p>The number of declined updates that would be removed from the database are: $AdamjRemoveDeclinedWSUSUpdatesCountUpdatesCount.</p>`n"

         # Variables Output
         # $AdamjRemoveDeclinedWSUSUpdatesCountUpdatesOutputTXT
         # $AdamjRemoveDeclinedWSUSUpdatesCountUpdatesOutputHTML
    }

    function RemoveDeclinedWSUSUpdatesDisplayUpdates {
        # Display the titles of the declined updates that will be removed from the database - just for fun. I like fun :)
        $Script:AdamjRemoveDeclinedWSUSUpdatesDisplayOutputHTML += "<ol>`n"
        $Count=0
        ForEach ($update in $AdamjRemoveDeclinedWSUSUpdatesUpdates) {
            $Count++
            $Script:AdamjRemoveDeclinedWSUSUpdatesDisplayOutputTXT += "$($Count). $($update.title) - https://support.microsoft.com/en-us/kb/$($update.KnowledgebaseArticles)`r`n"
            $Script:AdamjRemoveDeclinedWSUSUpdatesDisplayOutputHTML += "<li><a href=`"https://support.microsoft.com/en-us/kb/$($update.KnowledgebaseArticles)`">$($update.title)</a></li>`n"
        }
        $Script:AdamjRemoveDeclinedWSUSUpdatesDisplayOutputTXT += "`r`n"
        $Script:AdamjRemoveDeclinedWSUSUpdatesDisplayOutputHTML += "</ol>`n"
        
        # Variables Output
        # $AdamjRemoveDeclinedWSUSUpdatesDisplayOutputTXT
        # $AdamjRemoveDeclinedWSUSUpdatesDisplayOutputHTML
    }

    function RemoveDeclinedWSUSUpdatesProceed {
        Write-Host "You've chosen to remove declined updates from the database. Removing $AdamjRemoveDeclinedWSUSUpdatesCountUpdatesCount declined updates."
        Write-Host "Please be patient, this may take a while."
        $Script:AdamjRemoveDeclinedWSUSUpdatesProceedOutputTXT += "You've chosen to remove declined updates from the database. Removing $AdamjRemoveDeclinedWSUSUpdatesCountUpdatesCount declined updates.`r`n`r`n"
        $Script:AdamjRemoveDeclinedWSUSUpdatesProceedOutputHTML += "<p>You've chosen to remove declined updates from the database. <strong>Removing $AdamjRemoveDeclinedWSUSUpdatesCountUpdatesCount declined updates.</strong></p>`n"
        # Remove these updates
        $AdamjRemoveDeclinedWSUSUpdatesUpdates | ForEach-Object {
            $DeleteID = $_.Id.UpdateId.ToString()
            Try {
                $AdamjRemoveDeclinedWSUSUpdatesUpdateTitle = $($_.Title)
                Write-Host "Deleting" $AdamjRemoveDeclinedWSUSUpdatesUpdateTitle
                $AdamjWSUSServerAdminProxy.DeleteUpdate($DeleteId)
            }
            Catch {
                $ExceptionError = $_.Exception
                if ([string]::isnullorempty($AdamjRemoveDeclinedWSUSUpdatesProceedExceptionsTXT)) { $AdamjRemoveDeclinedWSUSUpdatesProceedExceptionsTXT = "" }
                if ([string]::isnullorempty($AdamjRemoveDeclinedWSUSUpdatesProceedExceptionsHTML)) { $AdamjRemoveDeclinedWSUSUpdatesProceedExceptionsHTML = "" }
                $AdamjRemoveDeclinedWSUSUpdatesProceedExceptionsTXT += "Error: $AdamjRemoveDeclinedWSUSUpdatesUpdateTitle`r`n`r`n$ExceptionError.InnerException`r`n`r`n"
                $AdamjRemoveDeclinedWSUSUpdatesProceedExceptionsHTML += "<li><p>$AdamjRemoveDeclinedWSUSUpdatesUpdateTitle</p>$ExceptionError.InnerException</li>"
            }
            Finally {
                Write-Host "Errors:" $ExceptionError.Message
            }
        }


        if (-not [string]::isnullorempty($AdamjRemoveDeclinedWSUSUpdatesProceedExceptionsTXT)) {
            $Script:AdamjRemoveDeclinedWSUSUpdatesProceedOutputTXT += "*** Errors Removing Declined WSUS Updates ***`r`n"
            $Script:AdamjRemoveDeclinedWSUSUpdatesProceedOutputTXT += $AdamjRemoveDeclinedWSUSUpdatesProceedExceptionsTXT
            $Script:AdamjRemoveDeclinedWSUSUpdatesProceedOutputTXT += "`r`n`r`n"
        }

        if (-not [string]::isnullorempty($AdamjRemoveDeclinedWSUSUpdatesProceedExceptionsHTML)) {
            $Script:AdamjRemoveDeclinedWSUSUpdatesProceedOutputHTML += @"
<style type="text/css">
.error {
border: 2px solid;
margin: 10px 10px;
padding:15px 50px 15px 50px;
}
.error ol {
color: #D8000C;
}
.error ol li p {
color: #000;
background-color: transparent;
}
.error ol li {
background-color: #FFBABA;
margin: 10px 0;
}
</style>
"@
            $Script:AdamjRemoveDeclinedWSUSUpdatesProceedOutputHTML += "<div class='error'><h1>Errors Removing Declined WSUS Updates</h1><ol start='1'>"
            $Script:AdamjRemoveDeclinedWSUSUpdatesProceedOutputHTML += $AdamjRemoveDeclinedWSUSUpdatesProceedExceptionsHTML
            $Script:AdamjRemoveDeclinedWSUSUpdatesProceedOutputHTML += "</ol></div>"
        }




        # Variables Output
        # $AdamjRemoveDeclinedWSUSUpdatesProceedOutputTXT
        # $AdamjRemoveDeclinedWSUSUpdatesProceedOutputHTML
    }
    
    
    RemoveDeclinedWSUSUpdatesCountUpdates
    if ($Display -ne $False) { RemoveDeclinedWSUSUpdatesDisplayUpdates }
    if ($Proceed -ne $False) { RemoveDeclinedWSUSUpdatesProceed }
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan –Start $DateNow –End $FinishedRunning
    
    $Script:AdamjRemoveDeclinedWSUSUpdatesOutputTXT += "Adamj Remove Declined WSUS Updates:`r`n`r`n"
    $Script:AdamjRemoveDeclinedWSUSUpdatesOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">Adamj Remove Declined WSUS Updates:</span></p>`n<ol>`n"
    $Script:AdamjRemoveDeclinedWSUSUpdatesOutputTXT += $AdamjRemoveDeclinedWSUSUpdatesCountUpdatesOutputTXT
    $Script:AdamjRemoveDeclinedWSUSUpdatesOutputHTML += $AdamjRemoveDeclinedWSUSUpdatesCountUpdatesOutputHTML
    if ($Display -ne $False) {
        $Script:AdamjRemoveDeclinedWSUSUpdatesOutputTXT += $AdamjRemoveDeclinedWSUSUpdatesDisplayOutputTXT
        $Script:AdamjRemoveDeclinedWSUSUpdatesOutputHTML += $AdamjRemoveDeclinedWSUSUpdatesDisplayOutputHTML
    }
    if ($Proceed -ne $False) {
        $Script:AdamjRemoveDeclinedWSUSUpdatesOutputTXT += $AdamjRemoveDeclinedWSUSUpdatesProceedOutputTXT
        $Script:AdamjRemoveDeclinedWSUSUpdatesOutputHTML += $AdamjRemoveDeclinedWSUSUpdatesProceedOutputHTML
    }
    $Script:AdamjRemoveDeclinedWSUSUpdatesOutputTXT += "Remove Declined WSUS Updates Stream Duration: {0:00}:{1:00}:{2:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})
    $Script:AdamjRemoveDeclinedWSUSUpdatesOutputHTML += "<p>Remove Declined WSUS Updates Stream Duration: {0:00}:{1:00}:{2:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})
    
    # Variables Output
    # $AdamjRemoveDeclinedWSUSUpdatesOutputTXT
    # $AdamjRemoveDeclinedWSUSUpdatesOutputHTML    
}

################################
#  Adamj WSUS DB Maintenance   #
#            Stream            #
################################

function WSUSDBMaintenance {
    Param (
    [Switch]$NoOutput
    )
  $DateNow = Get-Date
  $AdamjWSUSDBMaintenanceSQLScript = @"
/*
################################
#   Adamj WSUSDBMaintenance    #
#         SQL Script           #
#       Version 1.0            #
#      Taken from TechNet      #
#      referenced below.       #
#                              #
#        Adam Marshall         #
#     http://www.adamj.org     #
################################
*/
-- Taken from https://gallery.technet.microsoft.com/scriptcenter/6f8cde49-5c52-4abd-9820-f1d270ddea61

/****************************************************************************** 
This sample T-SQL script performs basic maintenance tasks on SUSDB 
1. Identifies indexes that are fragmented and defragments them. For certain 
   tables, a fill-factor is set in order to improve insert performance. 
   Based on MSDN sample at http://msdn2.microsoft.com/en-us/library/ms188917.aspx 
   and tailored for SUSDB requirements 
2. Updates potentially out-of-date table statistics. 
******************************************************************************/ 
 
USE SUSDB; 
GO 
SET NOCOUNT ON; 
 
-- Rebuild or reorganize indexes based on their fragmentation levels 
DECLARE @work_to_do TABLE ( 
    objectid int 
    , indexid int 
    , pagedensity float 
    , fragmentation float 
    , numrows int 
) 
 
DECLARE @objectid int; 
DECLARE @indexid int; 
DECLARE @schemaname nvarchar(130);  
DECLARE @objectname nvarchar(130);  
DECLARE @indexname nvarchar(130);  
DECLARE @numrows int 
DECLARE @density float; 
DECLARE @fragmentation float; 
DECLARE @command nvarchar(4000);  
DECLARE @fillfactorset bit 
DECLARE @numpages int 
 
-- Select indexes that need to be defragmented based on the following 
-- * Page density is low 
-- * External fragmentation is high in relation to index size 
PRINT 'Estimating fragmentation: Begin. ' + convert(nvarchar, getdate(), 121)  
INSERT @work_to_do 
SELECT 
    f.object_id 
    , index_id 
    , avg_page_space_used_in_percent 
    , avg_fragmentation_in_percent 
    , record_count 
FROM  
    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, 'SAMPLED') AS f 
WHERE 
    (f.avg_page_space_used_in_percent < 85.0 and f.avg_page_space_used_in_percent/100.0 * page_count < page_count - 1) 
    or (f.page_count > 50 and f.avg_fragmentation_in_percent > 15.0) 
    or (f.page_count > 10 and f.avg_fragmentation_in_percent > 80.0) 
 
PRINT 'Number of indexes to rebuild: ' + cast(@@ROWCOUNT as nvarchar(20)) 
 
PRINT 'Estimating fragmentation: End. ' + convert(nvarchar, getdate(), 121) 
 
SELECT @numpages = sum(ps.used_page_count) 
FROM 
    @work_to_do AS fi 
    INNER JOIN sys.indexes AS i ON fi.objectid = i.object_id and fi.indexid = i.index_id 
    INNER JOIN sys.dm_db_partition_stats AS ps on i.object_id = ps.object_id and i.index_id = ps.index_id 
 
-- Declare the cursor for the list of indexes to be processed. 
DECLARE curIndexes CURSOR FOR SELECT * FROM @work_to_do 
 
-- Open the cursor. 
OPEN curIndexes 
 
-- Loop through the indexes 
WHILE (1=1) 
BEGIN 
    FETCH NEXT FROM curIndexes 
    INTO @objectid, @indexid, @density, @fragmentation, @numrows; 
    IF @@FETCH_STATUS < 0 BREAK; 
 
    SELECT  
        @objectname = QUOTENAME(o.name) 
        , @schemaname = QUOTENAME(s.name) 
    FROM  
        sys.objects AS o 
        INNER JOIN sys.schemas as s ON s.schema_id = o.schema_id 
    WHERE  
        o.object_id = @objectid; 
 
    SELECT  
        @indexname = QUOTENAME(name) 
        , @fillfactorset = CASE fill_factor WHEN 0 THEN 0 ELSE 1 END 
    FROM  
        sys.indexes 
    WHERE 
        object_id = @objectid AND index_id = @indexid; 
 
    IF ((@density BETWEEN 75.0 AND 85.0) AND @fillfactorset = 1) OR (@fragmentation < 30.0) 
        SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REORGANIZE'; 
    ELSE IF @numrows >= 5000 AND @fillfactorset = 0 
        SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD WITH (FILLFACTOR = 90)'; 
    ELSE 
        SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD'; 
    PRINT convert(nvarchar, getdate(), 121) + N' Executing: ' + @command; 
    EXEC (@command); 
    PRINT convert(nvarchar, getdate(), 121) + N' Done.'; 
END 
 
-- Close and deallocate the cursor. 
CLOSE curIndexes; 
DEALLOCATE curIndexes; 
 
 
IF EXISTS (SELECT * FROM @work_to_do) 
BEGIN 
    PRINT 'Estimated number of pages in fragmented indexes: ' + cast(@numpages as nvarchar(20)) 
    SELECT @numpages = @numpages - sum(ps.used_page_count) 
    FROM 
        @work_to_do AS fi 
        INNER JOIN sys.indexes AS i ON fi.objectid = i.object_id and fi.indexid = i.index_id 
        INNER JOIN sys.dm_db_partition_stats AS ps on i.object_id = ps.object_id and i.index_id = ps.index_id 
 
    PRINT 'Estimated number of pages freed: ' + cast(@numpages as nvarchar(20)) 
END 
GO 
 
 
--Update all statistics 
PRINT 'Updating all statistics.' + convert(nvarchar, getdate(), 121)  
EXEC sp_updatestats 
PRINT 'Done updating statistics.' + convert(nvarchar, getdate(), 121)  
GO 
"@
    # Create a file with the content of the AdamjWsusDBMaintenance Script above in the
    # same working directory as this PowerShell script is running.
    $AdamjWSUSDBMaintenanceSQLScriptFile = "$AdamjScriptPath\AdamjWSUSDBMaintenance.sql"
    $AdamjWSUSDBMaintenanceSQLScript | Out-File $AdamjWSUSDBMaintenanceSQLScriptFile

    # Re-jig the $AdamjSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
    $AdamjSQLConnectCommand = $AdamjSQLConnectCommand.Replace('$','`$')
    # Execute the SQL Script and store the results in a variable.
    $AdamjWSUSDBMaintenanceSQLScriptJobCommand = [scriptblock]::create("$AdamjSQLConnectCommand -i $AdamjWSUSDBMaintenanceSQLScriptFile -I")
    $AdamjWSUSDBMaintenanceSQLScriptJob = Start-Job -ScriptBlock $AdamjWSUSDBMaintenanceSQLScriptJobCommand
    Wait-Job $AdamjWSUSDBMaintenanceSQLScriptJob
    $AdamjWSUSDBMaintenanceSQLScriptJobOutput = Receive-Job $AdamjWSUSDBMaintenanceSQLScriptJob
    Remove-Job $AdamjWSUSDBMaintenanceSQLScriptJob
    # Remove the SQL Script file.
    Remove-Item $AdamjWSUSDBMaintenanceSQLScriptFile
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan –Start $DateNow –End $FinishedRunning
    # Setup variables to store the output to be added at the very end of the script for logging purposes.
    
    if ($NoOutput -eq $False) {
        $Script:AdamjWSUSDBMaintenanceOutputTXT += "Adamj WSUS DB Maintenance:`r`n`r`n"
        $Script:AdamjWSUSDBMaintenanceOutputTXT += $AdamjWSUSDBMaintenanceSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n" 
        $Script:AdamjWSUSDBMaintenanceOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">Adamj WSUS DB Maintenance:</span></p>`n`n"
        $Script:AdamjWSUSDBMaintenanceOutputHTML += $AdamjWSUSDBMaintenanceSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","<br>`r`n" 
     } else {
        $Script:AdamjWSUSDBMaintenanceOutputTXT += "Adamj WSUS DB Maintenance:`r`n`r`n"
        $Script:AdamjWSUSDBMaintenanceOutputTXT += "The Adamj WSUS DB Maintenance Stream was run with the -NoOutput switch.`r`n`r`n"
        $Script:AdamjWSUSDBMaintenanceOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">Adamj WSUS DB Maintenance:</span></p>`n`n"
        $Script:AdamjWSUSDBMaintenanceOutputHTML += "<p>The Adamj WSUS DB Maintenance Stream was run with the -NoOutput switch.</p>`n`n"
     }
     $Script:AdamjWSUSDBMaintenanceOutputTXT += "WSUS DB Maintenance Stream Duration: {0:00}:{1:00}:{2:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})
     $Script:AdamjWSUSDBMaintenanceOutputHTML += "<p>WSUS DB Maintenance Stream Duration: {0:00}:{1:00}:{2:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $AdamjWSUSDBMaintenanceOutputTXT
    # $AdamjWSUSDBMaintenanceOutputHTML
}

################################
#   Adamj Decline Superseded  #
#        Updates Stream        #
################################

function DeclineSupersededUpdates {
    param (
    [Switch]$Display,
    [Switch]$Proceed
    )

    # Log the date first
    $DateNow = Get-Date
    # Create an update scope
    $UpdateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
    # by default the update scope is created for any approval states
    $UpdateScope.ApprovedStates = "Any"
    # Get all updates that have been Superseded and not Declined
    $AdamjDeclineSupersededUpdatesUpdates = $AdamjWSUSServerAdminProxy.GetUpdates($UpdateScope) | Where { ($_.IsSuperseded) -and -not ($_.isDeclined) }
    
    function DeclineSupersededUpdatesCountUpdates {
        # First count how many updates will be declined by Declining Superseded Updates - just for fun. I like fun :)
        $Script:AdamjDeclineSupersededUpdatesCountUpdatesCount = "{0:N0}" -f $AdamjDeclineSupersededUpdatesUpdates.Count
        $Script:AdamjDeclineSupersededUpdatesCountUpdatesOutputTXT += "The number of Superseded updates that would be declined are: $AdamjDeclineSupersededUpdatesCountUpdatesCount.`r`n`r`n"
        $Script:AdamjDeclineSupersededUpdatesCountUpdatesOutputHTML += "<p>The number of Superseded updates that would be declined are: $AdamjDeclineSupersededUpdatesCountUpdatesCount.</p>`n"

         # Variables Output
         # $AdamjDeclineSupersededUpdatesCountUpdatesOutputTXT
         # $AdamjDeclineSupersededUpdatesCountUpdatesOutputTXT
    }
    function DeclineSupersededUpdatesDisplayUpdates {
        # Display the titles of the Superseded updates that will be declined - just for fun. I like fun :)
        $Script:AdamjDeclineSupersededUpdatesUpdatesDisplayOutputHTML += "<ol>`n"
        $Count=0
        ForEach ($update in $AdamjDeclineSupersededUpdatesUpdates) {
            $Count++
            $Script:AdamjDeclineSupersededUpdatesUpdatesDisplayOutputTXT += "$($Count). $($update.title) - https://support.microsoft.com/en-us/kb/$($update.KnowledgebaseArticles)`r`n"
            $Script:AdamjDeclineSupersededUpdatesUpdatesDisplayOutputHTML += "<li><a href=`"https://support.microsoft.com/en-us/kb/$($update.KnowledgebaseArticles)`">$($update.title)</a></li>`n"
        }
        $Script:AdamjDeclineSupersededUpdatesUpdatesDisplayOutputTXT += "`r`n"
        $Script:AdamjDeclineSupersededUpdatesUpdatesDisplayOutputHTML += "</ol>`n"

        # Variables Output
        # $AdamjDeclineSupersededUpdatesUpdatesDisplayOutputTXT
        # $AdamjDeclineSupersededUpdatesUpdatesDisplayOutputHTML
    }
    function DeclineSupersededUpdatesProceed {
        $Script:AdamjDeclineSupersededUpdatesProceedOutputTXT += "You've chosen to Decline Superseded Updates. Declining $AdamjDeclineSupersededUpdatesCountUpdatesCount Superseded updates.`r`n`r`n"
        $Script:AdamjDeclineSupersededUpdatesProceedOutputHTML += "<p>You've chosen to Decline Superseded Updates. <strong>Declining $AdamjDeclineSupersededUpdatesCountUpdatesCount Superseded updates.</strong></p>`n"
        # Decline these updates
        $AdamjDeclineSupersededUpdatesUpdates | ForEach-Object -Process { $_.Decline() }

        # Variables Output
        # $AdamjDeclineSupersededUpdatesProceedOutputTXT
        # $AdamjDeclineSupersededUpdatesProceedOutputHTML
    }
    
    DeclineSupersededUpdatesCountUpdates
    if ($Display -ne $False) { DeclineSupersededUpdatesDisplayUpdates }
    if ($Proceed -ne $False) { DeclineSupersededUpdatesProceed }
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan –Start $DateNow –End $FinishedRunning

    $Script:AdamjDeclineSupersededUpdatesOutputTXT += "Adamj Decline Superseded Updates:`r`n"
    $Script:AdamjDeclineSupersededUpdatesOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">Adamj Decline Superseded Updates:</span><br>`n"
    $Script:AdamjDeclineSupersededUpdatesOutputTXT += $AdamjDeclineSupersededUpdatesCountUpdatesOutputTXT
    $Script:AdamjDeclineSupersededUpdatesOutputHTML += $AdamjDeclineSupersededUpdatesCountUpdatesOutputHTML
    if ($Display -ne $False) {
        $Script:AdamjDeclineSupersededUpdatesOutputTXT += $AdamjDeclineSupersededUpdatesUpdatesDisplayOutputTXT
        $Script:AdamjDeclineSupersededUpdatesOutputHTML += $AdamjDeclineSupersededUpdatesUpdatesDisplayOutputHTML
    }
    if ($Proceed -ne $False) {
        $Script:AdamjDeclineSupersededUpdatesOutputTXT += $AdamjDeclineSupersededUpdatesProceedOutputTXT
        $Script:AdamjDeclineSupersededUpdatesOutputHTML += $AdamjDeclineSupersededUpdatesProceedOutputHTML
    }
    $Script:AdamjDeclineSupersededUpdatesOutputTXT += "Decline Superseded Updates Stream Duration: {0:00}:{1:00}:{2:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})
    $Script:AdamjDeclineSupersededUpdatesOutputHTML += "<p>Decline Superseded Updates Stream Duration: {0:00}:{1:00}:{2:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})
}

################################
#        Clean Up WSUS         #
# Synchronization Logs Stream  #
################################

function CleanUpWSUSSynchronizationLogs {
    Param(
    [Int]$ConsistencyNumber,
    [String]$ConsistencyTime,
    [Switch]$All
    )
  $DateNow = Get-Date
  $AdamjCleanUpWSUSSynchronizationLogsSQLScript = @"
/*
################################
#  Adamj WSUS Synchronization  #
#      Cleanup SQL Script      #
#       Version 1.0            #
#  Taken from various sources  #
#      from the Internet.      #
#                              #
#  Modified By: Adam Marshall  #
#     http://www.adamj.org     #
################################
*/
$(
    if ($ConsistencyNumber -ne "0") {
    $("
USE SUSDB
GO
DELETE FROM tbEventInstance WHERE EventNamespaceID = '2' AND EVENTID IN ('381', '382', '384', '386', '387', '389') AND DATEDIFF($($ConsistencyTime), TimeAtServer, CURRENT_TIMESTAMP) >= $($ConsistencyNumber);
GO")
} 
elseif ($All -ne $False) {
$("USE SUSDB
GO
DELETE FROM tbEventInstance WHERE EventNamespaceID = '2' AND EVENTID IN ('381', '382', '384', '386', '387', '389')
GO")
}
)
"@
    # Create a file with the content of the AdamjCleanUpWSUSSynchronizationLogs Script above in the
    # same working directory as this PowerShell script is running.
    $AdamjCleanUpWSUSSynchronizationLogsSQLScriptFile = "$AdamjScriptPath\AdamjCleanUpWSUSSynchronizationLogs.sql"
    $AdamjCleanUpWSUSSynchronizationLogsSQLScript | Out-File $AdamjCleanUpWSUSSynchronizationLogsSQLScriptFile
    # Re-jig the $AdamjSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
    $AdamjSQLConnectCommand = $AdamjSQLConnectCommand.Replace('$','`$')
    # Execute the SQL Script and store the results in a variable.
    $AdamjCleanUpWSUSSynchronizationLogsSQLScriptJobCommand = [scriptblock]::create("$AdamjSQLConnectCommand -i $AdamjCleanUpWSUSSynchronizationLogsSQLScriptFile -I")
    $AdamjCleanUpWSUSSynchronizationLogsSQLScriptJob = Start-Job -ScriptBlock $AdamjCleanUpWSUSSynchronizationLogsSQLScriptJobCommand
    Wait-Job $AdamjCleanUpWSUSSynchronizationLogsSQLScriptJob
    $AdamjCleanUpWSUSSynchronizationLogsSQLScriptJobOutput = Receive-Job $AdamjCleanUpWSUSSynchronizationLogsSQLScriptJob
    Remove-Job $AdamjCleanUpWSUSSynchronizationLogsSQLScriptJob
    # Remove the SQL Script file.
    Remove-Item $AdamjCleanUpWSUSSynchronizationLogsSQLScriptFile
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan –Start $DateNow –End $FinishedRunning

    # Setup variables to store the output to be added at the very end of the script for logging purposes.
    $Script:AdamjCleanUpWSUSSynchronizationLogsSQLOutputTXT += "Adamj Clean Up WSUS Synchornization Logs:`r`n`r`n"
    $Script:AdamjCleanUpWSUSSynchronizationLogsSQLOutputTXT += $AdamjCleanUpWSUSSynchronizationLogsSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n" 
    $Script:AdamjCleanUpWSUSSynchronizationLogsSQLOutputTXT += "Clean Up WSUS Synchronization Logs Stream Duration: {0:00}:{1:00}:{2:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})

    $Script:AdamjCleanUpWSUSSynchronizationLogsSQLOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">Adamj Clean Up WSUS Synchornization Logs:</span></p>`r`n"
    $Script:AdamjCleanUpWSUSSynchronizationLogsSQLOutputHTML += $AdamjCleanUpWSUSSynchronizationLogsSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","<br>`r`n" 
    $Script:AdamjCleanUpWSUSSynchronizationLogsSQLOutputHTML += "<p>Clean Up WSUS Synchronization Logs Stream Duration: {0:00}:{1:00}:{2:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $AdamjCleanUpWSUSSynchronizationLogsSQLOutputTXT
    # $AdamjCleanUpWSUSSynchronizationLogsSQLOutputHTML
    
}

################################
#  WSUS Server Cleanup Wizard  #
#            Stream            #
################################

function WSUSServerCleanupWizard {
    $DateNow = Get-Date
    $WSUSServerCleanupWizardBody = "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUS Server Cleanup Wizard:</span></p>" | Out-String
    $CleanupManager = $AdamjWSUSServerAdminProxy.GetCleanupManager();
    $CleanupScope = New-Object Microsoft.UpdateServices.Administration.CleanupScope ($AdamjSCWSupersededUpdatesDeclined,$AdamjSCWExpiredUpdatesDeclined,$AdamjSCWObsoleteUpdatesDeleted,$AdamjSCWUpdatesCompressed,$AdamjSCWObsoleteComputersDeleted,$AdamjSCWUnneededContentFiles);
    $AdamjCleanupResults = $CleanupManager.PerformCleanup($CleanupScope)
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan –Start $DateNow –End $FinishedRunning


    $AdamjCSSStyling =@"
<style type="text/css">
table.gridtable {
    font-family: verdana,arial,sans-serif;
    font-size:11px;
    color:#333333;
    border-width: 1px;
    border-color: #666666;
    border-collapse: collapse;
}
table.gridtable th {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #dedede;
}
table.gridtable td {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #ffffff;
}
.TFtable{
    border-collapse:collapse;
}
.TFtable td{
    padding:7px;
    border:#4e95f4 1px solid;
}

/* provide some minimal visual accommodation for IE8 and below */
.TFtable tr{
    background: #b8d1f3;
}
/* Define the background color for all the ODD background rows */
.TFtable tr:nth-child(odd){
    background: #b8d1f3;
}
/* Define the background color for all the EVEN background rows */
.TFtable tr:nth-child(even){
    background: #dae5f4;
}
</style>
"@
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "Adamj WSUS Server Cleanup Wizard:`r`n`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "$AdamjWSUSServer`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "Version: $($AdamjWSUSServerAdminProxy.Version)`r`n"
    #$Script:AdamjWSUSServerCleanupWizardOutputTXT += "Started: $($DateNow.ToString("yyyy.MM.dd hh:mm:ss tt zzz"))`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "SupersededUpdatesDeclined: $($AdamjCleanupResults.SupersededUpdatesDeclined)`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "ExpiredUpdatesDeclined: $($AdamjCleanupResults.ExpiredUpdatesDeclined)`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "ObsoleteUpdatesDeleted: $($AdamjCleanupResults.ObsoleteUpdatesDeleted)`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "UpdatesCompressed: $($AdamjCleanupResults.UpdatesCompressed)`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "ObsoleteComputersDeleted: $($AdamjCleanupResults.ObsoleteComputersDeleted)`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "DiskSpaceFreed (MB): $([math]::round($AdamjCleanupResults.DiskSpaceFreed/1MB, 2))`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "DiskSpaceFreed (GB): $([math]::round($AdamjCleanupResults.DiskSpaceFreed/1GB, 2))`r`n"
    #$Script:AdamjWSUSServerCleanupWizardOutputTXT += "Finished: $($FinishedRunning.ToString("yyyy.MM.dd hh:mm:ss tt zzz"))`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputTXT += "WSUS Server Cleanup Wizard Duration: {0:00}:{1:00}:{2:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})
    
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">Adamj WSUS Server Cleanup Wizard:</span></p>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += $AdamjCSSStyling + "`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<table class=`"gridtable`">`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tbody>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><th colspan=`"2`" rowspan=`"1`">$AdamjWSUSServer</th></tr>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>Version:</td><td>$($AdamjWSUSServerAdminProxy.Version)</td></tr>`r`n"
    #$Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>Started:</td><td>$($DateNow.ToString("yyyy.MM.dd hh:mm:ss tt zzz"))</td></tr>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>SupersededUpdatesDeclined:</td><td>$($AdamjCleanupResults.SupersededUpdatesDeclined)</td></tr>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>ExpiredUpdatesDeclined:</td><td>$($AdamjCleanupResults.ExpiredUpdatesDeclined)</td></tr>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>ObsoleteUpdatesDeleted:</td><td>$($AdamjCleanupResults.ObsoleteUpdatesDeleted)</td></tr>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>UpdatesCompressed:</td><td>$($AdamjCleanupResults.UpdatesCompressed)</td></tr>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>ObsoleteComputersDeleted:</td><td>$($AdamjCleanupResults.ObsoleteComputersDeleted)</td></tr>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>DiskSpaceFreed (MB):</td><td>$([math]::round($AdamjCleanupResults.DiskSpaceFreed/1MB, 2))</td></tr>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>DiskSpaceFreed (GB):</td><td>$([math]::round($AdamjCleanupResults.DiskSpaceFreed/1GB, 2))</td></tr>`r`n"
    #$Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>Finished:</td><td>$($FinishedRunning.ToString("yyyy.MM.dd hh:mm:ss tt zzz"))</td></tr>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "<tr><td>WSUS Server Cleanup Wizard Duration:</td><td>{0:00}:{1:00}:{2:00}</td></tr>`r`n" -f ($DifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "</tbody>`r`n"
    $Script:AdamjWSUSServerCleanupWizardOutputHTML += "</table>`r`n"

    Remove-Variable AdamjCleanupResults
    # Variables Output
    # $AdamjWSUSServerCleanupWizardOutputTXT
    # $AdamjWSUSServerCleanupWizardOutputHTML
}


function AdamjScriptDifferenceInTime {
    $AdamjScriptFinishedRunning = Get-Date
    $Script:AdamjScriptDifferenceInTime = New-TimeSpan –Start $AdamjScriptTime –End $AdamjScriptFinishedRunning
}

################################
#     Create the TXT output    #
################################

function CreateBodyTXT {
    $Script:AdamjBodyTXT = "`n"
    $Script:AdamjBodyTXT += $AdamjBodyHeaderTXT
    $Script:AdamjBodyTXT += $AdamjConnectedTXT
    $Script:AdamjBodyTXT += $AdamjDeclineSupersededUpdatesOutputTXT
    $Script:AdamjBodyTXT += $AdamjCleanUpWSUSSynchronizationLogsSQLOutputTXT
    $Script:AdamjBodyTXT += $AdamjRemoveWSUSDriversOutputTXT
    $Script:AdamjBodyTXT += $AdamjRemoveDeclinedWSUSUpdatesOutputTXT
    $Script:AdamjBodyTXT += $AdamjWSUSDBMaintenanceOutputTXT
    $Script:AdamjBodyTXT += $AdamjWSUSServerCleanupWizardOutputTXT
    $Script:AdamjBodyTXT += "Clean-WSUS Script Duration: {0:00}:{1:00}:{2:00}`r`n`r`n" -f ($AdamjScriptDifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})
    $Script:AdamjBodyTXT += $AdamjBodyFooterTXT
}
        
################################
#    Create the HTML output    #
################################

function CreateBodyHTML {
    $Script:AdamjBodyHTML = "`n"
    $Script:AdamjBodyHTML += $AdamjBodyHeaderHTML
    $Script:AdamjBodyHTML += $AdamjConnectedHTML
    $Script:AdamjBodyHTML += $AdamjDeclineSupersededUpdatesOutputHTML
    $Script:AdamjBodyHTML += $AdamjCleanUpWSUSSynchronizationLogsSQLOutputHTML
    $Script:AdamjBodyHTML += $AdamjRemoveWSUSDriversOutputHTML
    $Script:AdamjBodyHTML += $AdamjRemoveDeclinedWSUSUpdatesOutputHTML
    $Script:AdamjBodyHTML += $AdamjWSUSDBMaintenanceOutputHTML
    $Script:AdamjBodyHTML += $AdamjWSUSServerCleanupWizardOutputHTML
    $Script:AdamjBodyHTML += "<p>Clean-WSUS Script Duration: {0:00}:{1:00}:{2:00}</p>`r`n" -f ($AdamjScriptDifferenceInTime | % {$_.Hours, $_.Minutes, $_.Seconds})
    $Script:AdamjBodyHTML += $AdamjBodyFooterHTML
}



################################
#       Save the Report        #
################################

function SaveReport {
    Param(
    [ValidateSet("TXT","HTML")] 
    [String]$ReportType = "TXT"
    )
    if ($ReportType -eq "HTML") {
        $AdamjBodyHTML | Out-File -FilePath "$AdamjScriptPath\$(get-date -f "yyyy.MM.dd-HH.mm.ss").htm"
    } else {
        $AdamjBodyTXT | Out-File -FilePath "$AdamjScriptPath\$(get-date -f "yyyy.MM.dd-HH.mm.ss").txt"
    }
}

################################
#       Mail the Report        #
################################

function MailReport {
    param (
        [ValidateSet("TXT","HTML")] 
        [String] $MessageContentType = "HTML"
    )
    $message = New-Object System.Net.Mail.MailMessage
    $mailer = New-Object System.Net.Mail.SmtpClient ($AdamjMailReportSMTPServer, $AdamjMailReportSMTPPort)
    $mailer.EnableSSL = $AdamjMailReportSMTPServerEnableSSL
    if ($AdamjMailReportSMTPServerUsername -ne "") {
        $mailer.Credentials = New-Object System.Net.NetworkCredential($AdamjMailReportSMTPServerUsername, $AdamjMailReportSMTPServerPassword)
    }
    $message.From = $AdamjMailReportEmailFromAddress
    $message.To.Add($AdamjMailReportEmailToAddress)
    $message.Subject = $AdamjMailReportEmailSubject
    $message.Body = if ($MessageContentType -eq "HTML") { $AdamjBodyHTML } else { $AdamjBodyTXT }
    $message.IsBodyHtml = if ($MessageContentType -eq "HTML") { $True } else { $False }
    $mailer.send(($message))
}

################################
#           Help Me            #
################################

function HelpMe {
    ((Get-CimInstance Win32_OperatingSystem)  | Format-List @{Name="OS Name";Expression={$_.Caption}}, @{Name="OS Architecture";Expression={$_.OSArchitecture}}, @{Name="Version";Expression={$_.Version}}, @{Name="ServicePackMajorVersion";Expression={$_.ServicePackMajorVersion}}, @{Name="ServicePackMinorVersion";Expression={$_.ServicePackMinorVersion}} | Out-String).Trim()
    Write-Host "PowerShell Version:" $PSVersionTable.PSVersion.ToString()
    Write-Host "WSUS Version: $($AdamjWSUSServerAdminProxy.Version)"
    Write-Host "Replica Server: "$AdamjWSUSServerAdminProxy.GetConfiguration().IsReplicaServer
    Write-Host "The path to the WSUS Content folder is:" $AdamjWSUSServerAdminProxy.GetConfiguration().LocalContentCachePath
    Write-Host "Free Space on the WSUS Content folder Volume is:" (Get-DiskFree -Format | ? { $_.Type -like '*fixed*' } | Where-Object { ($_.Vol -eq ($AdamjWSUSServerAdminProxy.GetConfiguration().LocalContentCachePath).split("\")[0]) }).Avail
    Write-Host "All Volumes on the WSUS Server:"
    (Get-DiskFree -Format | Out-String).Trim()
    Write-Host ".NET Installed Versions"
    (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name Version -EA 0 | Where { $_.PSChildName -Match '^(?!S)\p{L}'} | Format-Table PSChildName, Version -AutoSize | Out-String).Trim()
    Write-Host "============================="
    Write-Host "All Adamj Variables"
    Write-Host "============================="
    (Get-Variable | Where-Object { $_.Name -match "Adamj" } | Format-Table -AutoSize | Out-String).Trim()
    Write-Host "============================="
    Write-Host " End of HelpMe Stream"
    Write-Host "============================="

}

################################
#    Process the Functions     #
################################

if ($FirstRun -eq $True) {
    $DailyRun = $False
    CreateAdamjHeader
    Write-Host "Executing RemoveWSUSDrivers"
    RemoveWSUSDrivers -SQL
    Write-Host "Executing DeclineSupersededUpdates"
    if ($AdamjWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineSupersededUpdates -Display -Proceed } else { Write-Host "This WSUS Server is a Replica Server. You can't decline superseded updates from a replica server. Skipping this stream."}
    Write-Host "Executing CleanUpWSUSSynchronizationLogs"
    if ($AdamjCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $AdamjCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $AdamjCleanUpWSUSSynchronizationLogsConsistencyTime }
    Write-Host "Executing WSUSDBMaintenance"
    WSUSDBMaintenance
    Write-Host "Executing WSUSServerCleanupWizard"
    WSUSServerCleanupWizard
    CreateAdamjFooter
    AdamjScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    SaveReport
    MailReport
}
if ($MonthlyRun -eq $True) {
    $DailyRun = $False
    CreateAdamjHeader
    #Write-Host "Executing DeclineSupersededUpdates"
    if ($AdamjWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineSupersededUpdates -Display -Proceed } else { Write-Host "This WSUS Server is a Replica Server. You can't decline superseded updates from a replica server. Skipping this stream."}
    #Write-Host "Executing CleanUpWSUSSynchronizationLogs"
    if ($AdamjCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $AdamjCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $AdamjCleanUpWSUSSynchronizationLogsConsistencyTime }
    #Write-Host "Executing WSUSDBMaintenance"
    WSUSDBMaintenance
    #Write-Host "Executing WSUSServerCleanupWizard"
    WSUSServerCleanupWizard
    CreateAdamjFooter
    AdamjScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    MailReport
}
if ($QuarterlyRun -eq $True) {
    $DailyRun = $False
    CreateAdamjHeader
    Write-Host "Executing DeclineSupersededUpdates"
    if ($AdamjWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineSupersededUpdates -Display -Proceed } else { Write-Host "This WSUS Server is a Replica Server. You can't decline superseded updates from a replica server. Skipping this stream."}
    Write-Host "Executing CleanUpWSUSSynchronizationLogs"
    if ($AdamjCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $AdamjCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $AdamjCleanUpWSUSSynchronizationLogsConsistencyTime }
    Write-Host "Executing RemoveWSUSDrivers"
    RemoveWSUSDrivers
    Write-Host "Executing RemoveDeclinedWSUSUpdates"
    RemoveDeclinedWSUSUpdates -Display -Proceed
    Write-Host "Executing WSUSDBMaintenance"
    WSUSDBMaintenance
    Write-Host "Executing WSUSServerCleanupWizard"
    WSUSServerCleanupWizard
    CreateAdamjFooter
    AdamjScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    MailReport
}
if ($ScheduledRun -eq $True) {
    $DailyRun = $False
    $DateNow = Get-Date
    CreateAdamjHeader
    if ($AdamjScheduledRunStreamsDay -gt 31 -or $AdamjScheduledRunStreamsDay -eq 0) { write-host 'You failed to set a valid value for $AdamjScheduledRunStreamsDay. Setting to 31'; $AdamjScheduledRunStreamsDay = 31 }
    Write-Host "Executing DeclineSupersededUpdates"
    if ($AdamjScheduledRunStreamsDay -eq $DateNow.Day) { if ($AdamjWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineSupersededUpdates -Display -Proceed } else { Write-Host "This WSUS Server is a Replica Server. You can't decline superseded updates from a replica server. Skipping this stream."} } else { if ($AdamjWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineSupersededUpdates } else { Write-Host "This WSUS Server is a Replica Server. You can't decline superseded updates from a replica server. Skipping this stream."} }
    Write-Host "Executing CleanUpWSUSSynchronizationLogs"
    if ($AdamjCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $AdamjCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $AdamjCleanUpWSUSSynchronizationLogsConsistencyTime }
    $AdamjScheduledRunQuarterlyMonths.Split(",") | ForEach-Object {
	    if ($_ -eq $DateNow.Month) {
		    if ($_ -eq 2) {
                if ($AdamjScheduledRunStreamsDay -gt 28 -and [System.DateTime]::isleapyear($DateNow.Year) -eq $True) { $AdamjScheduledRunStreamsDay = 29 }
                else { $AdamjScheduledRunStreamsDay = 28 }
		    }
		    if (4,6,9,11 -contains $_ -and $AdamjScheduledRunStreamsDay -gt 30) { $AdamjScheduledRunStreamsDay = 30 }
            if ($AdamjScheduledRunStreamsDay -eq $DateNow.Day) {
			    Write-Host "Executing RemoveWSUSDrivers"
			    RemoveWSUSDrivers
			    Write-Host "Executing RemoveDeclinedWSUSUpdates"
			    RemoveDeclinedWSUSUpdates -Display -Proceed
		    }
	    }
    }    
    Write-Host "Executing WSUSDBMaintenance"
    if ($AdamjScheduledRunStreamsDay -eq $DateNow.Day) { WSUSDBMaintenance } else { WSUSDBMaintenance -NoOutput }
    Write-Host "Executing WSUSServerCleanupWizard"
    WSUSServerCleanupWizard
    CreateAdamjFooter
    AdamjScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    MailReport
}

if ($DailyRun -eq $True) {
    CreateAdamjHeader
    Write-Host "Executing DeclineSupersededUpdates"
    if ($AdamjWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineSupersededUpdates } else { Write-Host "This WSUS Server is a Replica Server. You can't decline superseded updates from a replica server. Skipping this stream."}
    Write-Host "Executing CleanUpWSUSSynchronizationLogs"
    if ($AdamjCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $AdamjCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $AdamjCleanUpWSUSSynchronizationLogsConsistencyTime }
    Write-Host "Executing WSUSDBMaintenance"
    WSUSDBMaintenance -NoOutput
    Write-Host "Executing WSUSServerCleanupWizard"
    WSUSServerCleanupWizard
    CreateAdamjFooter
    AdamjScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    MailReport
}

if ($FirstRun -eq $False -and $MonthlyRun -eq $False -and $QuarterlyRun -eq $False -and $ScheduledRun -eq $False -and $DailyRun -eq $False) {
    CreateAdamjHeader
    if ($RemoveWSUSDriversSQL -eq $True) { Write-Host "Executing RemoveWSUSDrivers using SQL"; RemoveWSUSDrivers -SQL }
    if ($RemoveWSUSDriversPS -eq $True) { Write-Host "Executing RemoveWSUSDrivers using Powershell"; RemoveWSUSDrivers }
    if ($RemoveDeclinedWSUSUpdates -eq $True) { Write-Host "Executing RemoveDeclinedWSUSUpdates"; RemoveDeclinedWSUSUpdates -Display -Proceed }
    if ($WSUSDBMaintenance -eq $True) { Write-Host "Executing WSUSDBMaintenance"; WSUSDBMaintenance }
    if ($DeclineSupersededUpdates -eq $True) { Write-Host "Executing DeclineSupersededUpdates"; if ($AdamjWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineSupersededUpdates -Display -Proceed } else { Write-Host "This WSUS Server is a Replica Server. You can't decline superseded updates from a replica server. Skipping this stream."} }
    if ($CleanUpWSUSSynchronizationLogs -eq $True) { Write-Host "Executing CleanUpWSUSSynchronizationLogs"; if ($AdamjCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $AdamjCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $AdamjCleanUpWSUSSynchronizationLogsConsistencyTime } }
    if ($WSUSServerCleanupWizard -eq $True) { Write-Host "Executing WSUSServerCleanupWizard"; WSUSServerCleanupWizard }
    CreateAdamjFooter
    AdamjScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    if ($SaveReport -eq "TXT") { SaveReport }
    if ($SaveReport -eq "HTML") { SaveReport -ReportType "HTML" }
    if ($MailReport -eq "HTML") { MailReport }
    if ($MailReport -eq "TXT") { MailReport -MessageContentType "TXT" }
}

if ($HelpMe -eq $True) {
    HelpMe
}

<#
# All Possible Function Calls

CreateAdamjHeader
RemoveWSUSDrivers -SQL
    RemoveWSUSDriversSQL
    RemoveWSUSDriversPS
RemoveDeclinedWSUSUpdates -Display -Proceed
    RemoveDeclinedWSUSUpdatesProceed
    RemoveDeclinedWSUSUpdatesDisplayUpdates
    RemoveDeclinedWSUSUpdatesCountUpdates
WSUSDBMaintenance -NoOutput
DeclineSupersededUpdates -Display -Proceed
    DeclineSupersededUpdatesProceed
    DeclineSupersededUpdatesDisplayUpdates
    DeclineSupersededUpdatesCountUpdates
CleanUpWSUSSynchronizationLogs -ConsistencyNumber "14" -ConsistencyTime "Day" -All
WSUSServerCleanupWizard
CreateAdamjFooter
CreateBodyTXT
CreateBodyHTML
SaveReport -ReportType
MailReport -MessageContentType
HelpMe
#>


################################
#      Clean Up Variables      #
################################

Get-Variable | Where-Object { $_.Name -match "Adamj" } | Remove-Variable

################################
#         End Of Code          #
################################

<#
################################
# For Future Additions to Code #
################################

Streamline the functions to be more consistent.

Add a powershell function to create scheduled task.


In more than how many days that computers have not synced with the WSUS Server
$AdamjComputerSearchDays = 30
$AdamjComputerSearchTimeSpan = new-object TimeSpan($AdamjComputerSearchDays,0,0,0)
$computerScope = new-object Microsoft.UpdateServices.Administration.ComputerTargetScope
$computerScope.ToLastSyncTime = [DateTime]::UtcNow.Subtract($AdamjComputerSearchTimeSpan)
$AdamjWSUSServerAdminProxy.GetComputerTargets($computerScope) | sort fulldomainname | ft fulldomainname,lastsynctime

If you wish to remove them then simply change the last line to:
$AdamjWSUSServerAdminProxy.GetComputerTargets($computerScope) | foreach-object {$_.Delete();}

# you would have to get the desired TimeSpan values to the Format operator
'{0:00}:{1:00}:{2:00}' -f $elapsed.Hours, $elapsed.Minutes, elapsed.Seconds
'{0:00}:{1:00}:{2:00}' -f ($elapsed | % {$_.Hours, $_.Minutes, $_.Seconds})

#(Get-CimInstance Win32_OperatingSystem) | Select-Object -Property *

#>
#EOF