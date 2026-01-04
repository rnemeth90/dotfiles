
#$2013Path = "C:\Program Files\Microsoft Office\Office15\OUTLOOK.EXE"
$2016Path = "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"

function office2016(){
    $key = "HKCU:\software\Microsoft\Office\16.0\Outlook\Profiles"
    $child = Get-ChildItem -path $Key 
    $profileName = $child.pschildname
    $value = $env:USERNAME + "@vibehcm.com"
    $key2 = "HKCU:\software\Microsoft\Office\16.0\Outlook\Profiles\$profileName\9375CFF0413111d3B88A00104B2A6676\00000002\"

    Set-ItemProperty -path $key2 -name "Account Name" -Value $value
}

#function  office2013(){
#    $key = "HKCU:\software\Microsoft\Office\15.0\Outlook\Profiles"
#    $child = Get-ChildItem -path $Key 
#    $profileName = $child.pschildname
#    $value = $env:USERNAME + "@vibehcm.com"
#    $key2 = "HKCU:\software\Microsoft\Office\15.0\Outlook\Profiles\$profileName\9375CFF0413111d3B88A00104B2A6676\00000002\"

#    Set-ItemProperty -path $key2 -name "Account Name" -Value $value
#}

if(Test-Path $2016Path){
    office2016
}
#elseif(Test-Path $2013Path){
#    office2013
#}
#else{
#    continue
#}

