#############################################
#Change these variables per your environment#
#############################################
$passdir = "c:\pass.txt"
$username = "365admin@ecipay.onmicrosoft.com"
$apiPath = "E:\Exchange2016\Bin\Microsoft.Exchange.WebServices.dll"
$date = (Get-Date).AddDays(-7)
$retPolicyName = ""



############################################
## DO NOT CHANGE ANYTHING BELOW THIS LINE ##
############################################

#Connect to Exchange Online
$pass = Get-Content $passdir | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object -TypeName system.management.automation.pscredential -args $username,$pass
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $session -AllowClobber

#Load Exchange Web Services API
$ewsApi = $apiPath
[Reflection.Assembly]::LoadFile($ewsApi) | out-null
$MailboxesPolicy = Get-Mailbox | Where {$_.RetentionPolicy -eq $retPolicyName} | Select-Object -ExpandProperty  WindowsEmailAddress

$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService($ExchangeVersion)
$service.Credentials = New-Object System.Net.NetworkCredential($username,$pass)
$deletedFolder = [Microsoft.Exchange.Webservices.Data.WellKnownFolderName]::DeletedItems

$fvFolderView = new-object Microsoft.Exchange.WebServices.Data.FolderView(1)
$SfSearchFilterDeleted = new-object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo([Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName,"Deleted Items")

$service.AutodiscoverUrl("admin@domain.onmicrosoft.com",{$true})
$ivItemView = New-Object Microsoft.Exchange.WebServices.Data.ItemView(1000)


foreach($mailbox in $mailboxesPolicy1){
$folderId = new-object Microsoft.Exchange.Webservices.Data.FolderId([Microsoft.Exchange.Webservices.Data.WellKnownFolderName]::MsgFolderRoot,$mailbox)
$iUserID = new-object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress,$mailbox)
$service.ImpersonatedUserId = $iUserID

$findFolderResultsDeleted = $service.FindFolders($folderid,$SfSearchFilterDeleted,$fvFolderView)

$fiDeletedItems = $service.FindItems($findFolderResultsDeleted.Id,$ivItemView)

foreach($Item in $fiDeletedItems.Items){
    if ($Item.DateTimeReceived -le $today)
     {
    $Item.Delete([Microsoft.Exchange.WebServices.Data.DeleteMode]::HardDelete)
     }
   }
}
Get-PSSession | Remove-PSSession