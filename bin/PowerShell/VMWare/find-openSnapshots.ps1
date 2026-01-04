$admin='sa-SnapshotDetection' #user with rights to query data from Vcenter 
$PathPass='C:\Scripts\securestring1.txt' #path to file with stored credentials 
$VIServers=('sbdvisp01','sbdvisp02','sasvisp01') #VC servers names 
#$PathToReport='c:\temp' - optional - store report locally 
 
$password = Get-Content $PathPass | ConvertTo-SecureString 
 
$cred=New-Object System.Management.Automation.PsCredential($admin,$password) 
#$cred = Get-Credential
 
#header description 
#-------------------------------------------------------------------------------------------------------- 
$Header = @" 
    <style> 
    TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;} 
    TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;} 
    TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;} 
    </style> 
"@ 
 
#-------------------------------------------------------------------------------------------------------- 
#generate report 
#--------------------------------------------------------------------------------------------------------- 
If(-not (Get-Module VMware.VimAutomation.Core)){  Try { Add-Module VMware.VimAutomation.Core -ErrorAction Stop } 
    Catch { Write-Host "Unable to load PowerCLI, is it installed?" -ForegroundColor Red; Break } 
} 
 
foreach($viserver in $VIServers){ 
    Connect-VIServer $VIServer -Credential $Cred | Out-Null 
} 

$Report = Get-VM | Get-Snapshot | Select VM,Name,Description,@{Label="Size";Expression={"{0:N2} GB" -f ($_.SizeGB)}},Created,@{Label="Created by";Expression={''}} 
 
foreach($snap in $Report){ 
    $snap.'Created by'= Get-VIEvent -entity (get-vm $snap.vm) -type info -MaxSamples 1000 | Where { $_.FullFormattedMessage.contains("Create virtual machine snapshot")}| Select-Object -First 1 -ExpandProperty username 
} 
 
If(-not $Report){
    $Report = New-Object PSObject -Property @{ 
        VM = "No snapshots found on any VM's controlled by vCenter" 
        Name = "" 
        Description = "" 
        Size = "" 
        Created = "" 
    } 
} 
 
$Report = $Report | Select VM,Name,Description,Size,Created,"Created by" | ConvertTo-Html -Head $Header -PreContent "<p><h2>Snapshot Report - vCenter</h2></p><br>" #| Set-AlternatingRows -CSSEvenClass even -CSSOddClass odd 
#$Report | Out-File $PathToReport\SnapShotReport.html 
 
Disconnect-VIServer -Server * -Force -Confirm:$false 
#-------------------------------------------------------------------------------------------------------------------- 
#send email to  
#--------------------------------------------------- 
$smtpServer = "relay.vibehcm.com" #mailserver name 
$MailFrom = "VMSnapshots@ecipay.com" #sender name 
$mailto = "it_datacenter@vibehcm.com"  # recipient address 
$msg = new-object Net.Mail.MailMessage   
$smtp = new-object Net.Mail.SmtpClient($smtpServer)   
$msg.From = $MailFrom  
$msg.IsBodyHTML = $true  
$msg.To.Add($Mailto)   
$msg.Subject = "Report-Snapshots"  
$MailTextT =  $Report 
$msg.Body = $MailTextT  
$smtp.Send($msg)  
 
#------------------------------------------------------------- 