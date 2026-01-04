<#
    .SYNOPSIS 
     Enables AADRM and creates a transport rule for OME
    .EXAMPLE
     Enable-OME
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     This script configures Office 365 message encryption. The user will be prompted for a keyword to use for encrypting emails. 
     The keyword will be typed into the subject line of the email, and the message will then be encrypted.
    .Version
     1.0
#>

#Get credentials for Exchange Online/Office365
$cred = Get-Credential
$status = Get-IRMConfiguration

try{
    #Connect to Exchange Online
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $cred -Authentication Basic –AllowRedirection
    Import-PSSession $Session
}
catch{
    "Unable to connect to Exchange Online. Please try again."
}


$keyword = Read-Host "What keyword would you like to use for encrypting emails? "

if($status.InternalLicensingEnabled -eq $false){
    #Enable and configure IRM
    Set-IRMConfiguration –RMSOnlineKeySharingLocation "https://sp-rms.na.aadrm.com/TenantManagement/ServicePartner.svc"
    Import-RMSTrustedPublishingDomain -RMSOnline -name "RMS Online"
    Set-IRMConfiguration -InternalLicensingEnabled $true
}
else{
    Write-Host "AADRM has already been enabled. Creating the transport rule for encryption."
}



#Create the OME transport rule
try{
    New-TransportRule "OME" -SubjectContainsWords $keyword -ApplyOME $true
}
catch{
    Write-Host "Unable to create transport rule."
}

Clear-Host

Write-Host "Testing the configuration" -ForegroundColor Yellow

Test-IRMConfiguration -sender $cred.UserName