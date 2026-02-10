
<#
    .SYNOPSIS 
     Removes users specified in a CSV file. The CSV file must be named "users.csv" and exist within the same directory
     as the script. The column name in the CSV must be "UPN". 

    .PARAMETER Mode
     The script accepts one parameter that is mandatory. The
     parameter specifies whether the script runs in "test mode" or "real mode". Test mode does not actually make any 
     modifications. Real mode does. To use real mode, pass the value "real" to the "-mode" parameter. To use test mode, 
     pass "test" to the "-mode" parameter.
    
    .EXAMPLE
     BulkRemove-Office365Accounts -Mode Test
    
    .EXAMPLE
     BulkRemove-Office365Accounts -Mode Real
    
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
    
    .EXAMPLE
     BulkRemove-Office365Accounts.ps1 [-Mode <String>]
#>

# !!!!ADD SOME PARAMETERS HERE!!!!
#param(
#    [String]$mb,
#    [String]$usr
#)

##################
# FUNCTIONS
##################

function main(){
    #Prompt user for an option

    #Option 1 = Set Send As Permissions
    Write-Host "1) Set Send-As Permissions"

    #option 2 = Remove Send-As Permissions
    Write-Host "2) Remove Send-As Permissions"

    #Option 3 = Set Full Access Permissions
    Write-Host "3) Set Full-Access Permissions"

    #option 4 = Remove Full Access Permissions
    Write-Host "4) Remove Full-Access Permissions"

    $opt = Read-Host "Choose an option"
    $mb = Read-Host "Email address of the mailbox you are modifying permissions on (Example: Jdoe@contoso.com) "
    $usr = Read-Host "Email address of the person you are adding or removing permissions for (Example: Mary@contoso.com)"
    #$dom = 
}

function AddFullAccess($mb,$usr){
    Add-MailboxPermission -Identity $mb -User $usr -AccessRights Fullaccess -InheritanceType all
}


function RemoveFullAccess($mb,$usr){
    Remove-MailboxPermission -Identity $mb -User $usr -AccessRights FullAccess -InheritanceType All
}


function AddSendAs($mb,$usr){
    Add-ADPermission $mb -User $usr -Extendedrights "Send As"
}


function RemoveSendAs($mb,$usr){
    Remove-ADPermission $mb -User $usr -Extendedrights "Send As"
}



##################
# Run Main
##################

main



##################
# Test Main Vars
##################

if($mb -eq $null){
    main
}
elseif($usr -eq $null){
    main
}


##################
# LOGIC
##################

if($opt -eq "1"){
    AddSendAs($mb,$usr)
}
elseif($opt -eq "2"){
    RemoveSendAs($mb,$usr)
}
elseif($opt -eq "3"){
    AddFullAccess($mb,$usr)
}
elseif($opt -eq "4"){
    RemoveFullAccess($mb,$usr)
}
else{
    Write-Host "VAGUE ERROR MESSAGE"
}