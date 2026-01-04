param(
    # start date for query
    [Parameter(Mandatory=$true)]
    [datetime]$StartDate,
    # end date for query
    [Parameter(Mandatory=$true)]
    [datetime]$EndDate,
    # Path for results archive
    [Parameter(Mandatory=$true)]
    [String]$OutPath,
    # the recipient address
    [Parameter(Mandatory=$true)]
    [string]$RecipientAddress
)

$cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
$FileName = ([string]$StartDate).Replace('/','-')
$tempPath = "C:\temp"
#$outPath = "C:\temp"
#$StartDate = "02/28/2018"
#$EndDate = "03/01/2018"
Import-PSSession $Session -AllowClobber

if(!(Test-Path -Path $tempPath)){
    New-Item -ItemType directory -Path $tempPath
}

$index = 1
do
{
    $a = Get-MessageTrace -RecipientAddress $RecipientAddress -StartDate $StartDate -EndDate $EndDate -PageSize 5000 -Page $index | Select-Object recipientAddress,status,size,received,subject
    $a | export-csv $temp\$FileName.csv -Append

    $index ++
}
while ($index -le 100000 -and $a.count)

Remove-PSSession $Session

Compress-Archive 'C:\temp' -DestinationPath "$OutPath\MessageTrace.zip" -Update

#Remove-Item -Path C:\temp -Recurse -Force