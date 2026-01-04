<#
    .SYNOPSIS 
     This script gatheres usage information regarding mailboxes for all users in an Office 365 tenant.  
    .PARAMETER Mode
     The script accepts no parameters.
    .EXAMPLE
     <>
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>

#Connect to Exchange Online PowerShell
$creds = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell/" -Credential $creds -Authentication Basic -AllowRedirection
Import-PSSession $session

#Get all mailboxes and store in variable
$Mailboxes = Get-Mailbox -ResultSize Unlimited
 
#Create an array to store members of the object  
$MailboxSizes = @()
 
foreach($Mailbox in $Mailboxes)
{
 
                $store_obj = New-Object -TypeName psobject
               
                $MailboxStats = Get-MailboxStatistics -Identity $Mailbox.UserPrincipalname
               
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "UserPrincipalName" -Value $Mailbox.UserPrincipalName
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Last Logged In" -Value $MailboxStats.LastLogonTime
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Mailbox Size" -Value $MailboxStats.TotalItemSize
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Mailbox Item Count" -Value $MailboxStats.ItemCount
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Is Disabled" -Value $Mailbox.AccountDisabled
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Address Book Policy" -Value $Mailbox.AddressListMembership
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Forwarding" -Value $Mailbox.DeliverToMailboxAndForward
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Forwarding Address(es)" -Value $Mailbox.ForwardingAddress
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Email Addresses" -value $Mailbox.EmailAddresses
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "In-Place Holds" -Value $Mailbox.InPlaceHolds
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "DirSync Enabled" -Value $Mailbox.IsDirSynced
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Litigation Hold Enabled" -Value $Mailbox.LitigationHoldEnabled
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Max Send Size" -value $Mailbox.MaxSendSize
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Max Receive Size" -Value $Mailbox.MaxReceiveSize
                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Usage Location" -Value $Mailbox.UsageLocation



                $MailboxStats.it    
               
                if($Mailbox.ArchiveStatus -eq "Active") 
                {
                
                                $ArchiveStats = Get-MailboxStatistics -Identity $Mailbox.UserPrincipalname -Archive
                               
                                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Archive Size" -Value $ArchiveStats.TotalItemSize
                                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Archive Item Count" -Value $ArchiveStats.ItemCount
                                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Archive Name" -Value $ArchiveStats.ArchiveName
                                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Archive Quota" -Value $ArchiveStats.ArchiveQuota

 
                }
                else{
                
                                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Archive Size" -Value "No Archive"
                                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Archive Item Count" -Value "No Archive"
                                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Archive Name" -Value "No Archive"
                                Add-Member -InputObject $store_obj -MemberType NoteProperty -Name "Archive Quota" -Value "No Archive"
                }
               
                $MailboxSizes += $store_obj
}             
               
$MailboxSizes | Out-GridView -Title "Mailbox Info"
 
Get-PSSession | Remove-PSSession