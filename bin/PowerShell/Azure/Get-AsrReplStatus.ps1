$reportpath = ".\ASRReport.htm" 

if((test-path $reportpath) -like $false)
{
    new-item $reportpath -type file
}
$smtphost = "" 
$from = "" 
$email1 = ""
$timeout = "60"

###############################HTml Report Content############################
$report = $reportpath

Clear-Content $report 
Add-Content $report "<html>" 
Add-Content $report "<head>" 
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>" 
Add-Content $report '<title>ASR Status Report</title>' 
add-content $report '<STYLE TYPE="text/css">' 
add-content $report  "<!--" 
add-content $report  "td {" 
add-content $report  "font-family: Tahoma;" 
add-content $report  "font-size: 11px;" 
add-content $report  "border-top: 1px solid #999999;" 
add-content $report  "border-right: 1px solid #999999;" 
add-content $report  "border-bottom: 1px solid #999999;" 
add-content $report  "border-left: 1px solid #999999;" 
add-content $report  "padding-top: 0px;" 
add-content $report  "padding-right: 0px;" 
add-content $report  "padding-bottom: 0px;" 
add-content $report  "padding-left: 0px;" 
add-content $report  "}" 
add-content $report  "body {" 
add-content $report  "margin-left: 5px;" 
add-content $report  "margin-top: 5px;" 
add-content $report  "margin-right: 0px;" 
add-content $report  "margin-bottom: 10px;" 
add-content $report  "" 
add-content $report  "table {" 
add-content $report  "border: thin solid #000000;" 
add-content $report  "}" 
add-content $report  "-->" 
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='Lavender'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Azure Site Recovery Replication Status</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='IndianRed'>" 
Add-Content $report  "<td width='5%' align='center'><B>ServerName</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>Status</B></td>" 
#Add-Content $report  "<td width='10%' align='center'><B>Issue</B></td>" 

 
Add-Content $report "</tr>" 

# Variable Declaration
$CLIENT_SECRET = "@LRoXlOp.NuWhaGIY/sA6NJBbLZJ@496"
$CLIENT_ID = "92640966-8502-4858-94ac-99bbc369345e"
$TENANT_ID = "0d44ac37-7119-4ca2-ae03-ec1ee0932f0a"
 
Write-Host "Logging you in..."
$secpasswd = ConvertTo-SecureString $CLIENT_SECRET -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($CLIENT_ID, $secpasswd)
Connect-AzAccount -ServicePrincipal -Tenant $TENANT_ID -Credential $mycreds
 
# Clear the contents of log file
#Clear-Content -Path FILE_PATH_OF_VMSTATUS_LOG_FILE
 
# Enter the subscriptions where ASR is enabled
$Subscriptions = "prod-eciserver-paug-01"
foreach ($Subscription in $Subscriptions)
{
    # Select the subscription
    Select-AzSubscription -SubscriptionName $Subscription
 
    # get the list of recovery services vaults in the subscription
    $VaultObjs = Get-AzRecoveryServicesVault
    foreach ($VaultObj in $VaultObjs) 
    {
        # get and import vault settings file
        #$VaultFileLocation = Get-AzRecoveryServicesVaultSettingsFile -SiteRecovery -Vault $VaultObj
        #Import-AzRecoveryServicesAsrVaultSettingsFile -Path $VaultFileLocation.FilePath
        Set-AzRecoveryServicesAsrVaultContext -Vault $VaultObj
 
        # get the list of fabrics in a vault
        $Fabrics = Get-AzRecoveryServicesAsrFabric
        foreach ($Fabric in $Fabrics)
        {
            # get containers and protected items in a container
            $Containers = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $Fabric
            foreach ($Container in $Containers)
            {
                $items = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $Container
                foreach ($item in $items)
                {
                    $vmName = $item.FriendlyName
                    Add-Content $report "</tr><td bgcolor= 'Grey' align=center><B>$vmName<br></B></td></tr>"



                    # Initialize an empty error array for capturing error(s) of each protected item
                    $ItemError = ""
                    foreach ($ASRerror in $item.ReplicationHealthErrors)
                    {
                        $ItemError=$ItemError,$ASRerror.ErrorMessage
                    }
                     
                    # Capture the status of machines which are in critical state to a file
                    If(-Not($item.ReplicationHealth -eq "Normal"))
                    {
                        $ASRVMHealthStatus=$Subscription+"`t"+$VaultObj.Name+"`t"+$Item.FriendlyName+"`t"+$Item.ReplicationHealth+"`t"+$ItemError
                        $ASRVMHealthStatus | Out-File -Append -FilePath c:\temp\asrStatus.txt
                        Write-Host $ASRVMHealthStatus
                        Add-Content $report "</tr><td bgcolor= 'Red' align=center><B>Issue</B></td><br></tr>"

                    }
                    else {
                        Write-Host "No issues found for" $item.RecoveryAzureVmName 
                        #Add-Content $report "</tr><td bgcolor= 'Grey' align=center><B>$vmName<br></B></td></tr>"
                    }

                    <#
                    
                    
                    $dataRow = "
                    </tr>
                    <td>$DriveLetter</td>
                    <td>$SizeGB GB</td>
                    <td>$FreeSpaceGB GB</td>
                    <td>$PercentFree %</td>
                    </tr>
                    "
                    $diskreport += $datarow
                    #>
                }
            }
        }
    }
 
        # remove vault settings file
        #Remove-Item -Path $VaultFileLocation.FilePath
}


Add-Content $report "</tr>"
############################################Close HTMl Tables###########################


Add-content $report  "</table>" 
Add-Content $report "</body>" 
Add-Content $report "</html>" 


########################################################################################
#############################################Send Email#################################

<#

$subject = "Active Directory Health Monitor" 
$body = Get-Content ".\ADreport.htm" 
$smtp= New-Object System.Net.Mail.SmtpClient $smtphost 
$msg = New-Object System.Net.Mail.MailMessage 
$msg.To.Add($email1)
$msg.from = $from
$msg.subject = $subject
$msg.body = $body 
$msg.isBodyhtml = $true 
$smtp.send($msg) 

#>


########################################################################################

########################################################################################
 