#Connect to Exchange Online if not already connected
$checkConn = Get-PSSession
if($checkConn.ComputerName -ne "ps.outlook.com"){
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential (Get-Credential) -Authentication Basic -AllowRedirection
    Import-PSSession $session
}