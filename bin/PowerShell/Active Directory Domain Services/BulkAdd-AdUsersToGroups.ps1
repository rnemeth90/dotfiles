Param(
   [Parameter(Mandatory=$True)]
   [String]$File,
   [Parameter(Mandatory=$True)]
   [string]$Group,
   [Parameter(Mandatory=$True)]
   [string]$Mode

)

$users = get-aduser -filter * -SearchBase "ou=accounting dept,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
$users += get-aduser -filter * -SearchBase "ou=Customer Success,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=data and reporting services,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=database administration,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=executives,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=HR dept,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=IMP - Core Product Implementations,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=IMP - Open Enrollment/Benefits,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=IMP - Peripheral Products,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=IMP - Project Management,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=IMP - TLM,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=IT Operations,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=Marketing,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=OPS - ACA Customer Support,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=OPS - Administrative,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=OPS - Customer Support Tier I,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=OPS - Customer Support Tier II,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=OPS - Payroll,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=R&D - Product Development,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=R&D - Product Management,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=R&D - Product Research,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=R&D - Product Support,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=R&D - Targeted Solutions,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=Sales Dept,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=Tax Dept,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=R&D - Product Research,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000
#$users += get-aduser -filter * -SearchBase "ou=R&D - Product Research,ou=eci users,dc=ecimain,dc=ecipay,dc=com" -ResultSetSize 1000000


#$users = import-csv .\users.csv

if ($mode -eq "Test"){
    foreach($user in $users){
        if($user.Enabled -eq "True"){
            Add-ADGroupMember -Identity $Group -Members $user -WhatIf
        }
    }
}
elseif($Mode -eq "Real"){
    foreach($user in $users){
        if($user.Enabled -eq "True"){
            Add-ADGroupMember -Identity $Group -Members $user
        }
    }
}
else {
    Write-Host "You did something wrong. Please try again." -ForegroundColor Red
}