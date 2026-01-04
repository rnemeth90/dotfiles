Param($migrationCSVFileName = "migration.csv")

function O365Logon
{
	#Check for current open O365 sessions and allow the admin to either use the existing session or create a new one
	$session = Get-PSSession | ?{$_.ConfigurationName -eq 'Microsoft.Exchange'}
	if($session -ne $null)
	{
		$a = Read-Host "An open session to Office 365 already exists.  Do you want to use this session?  Enter y to use the open session, anything else to close and open a fresh session."
		if($a.ToLower() -eq 'y')
		{
			Write-Host "Using existing Office 365 Powershell Session." -ForeGroundColor Green
			return	
		}
		$session | Remove-PSSession
	}
	Write-Host "Please enter your Office 365 credentials" -ForeGroundColor Green
	$cred = Get-Credential
	$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic -AllowRedirection
	$importresults = Import-PSSession -Prefix "Cloud" $s
}

function Main
{

	#Verify the migration CSV file exists
	if(!(Test-Path $migrationCSVFileName))
	{
		Write-Host "File $migrationCSVFileName does not exist." -ForegroundColor Red
		Exit
	}
	
	#Import user list from migration.csv file
	$MigrationCSV = Import-Csv $migrationCSVFileName
	
	#Get mailbox list based on email addresses from CSV file
	$MailBoxList = $MigrationCSV | %{$_.EmailAddress} | Get-CloudMailbox
	$Users = @()

	#Get LegacyDN, Tenant, and On-Premise Email addresses for the users
	foreach($user in $MailBoxList)
	{
		$UserInfo = New-Object System.Object
	
		$CloudEmailAddress = $user.EmailAddresses | ?{($_ -match 'onmicrosoft') -and ($_ -cmatch 'smtp:')}	
		if ($CloudEmailAddress.Count -gt 1)
		{
			$CloudEmailAddress = $CloudEmailAddress[0].ToString().ToLower().Replace('smtp:', '')
			Write-Host "$user returned more than one cloud email address.  Using $CloudEmailAddress" -ForegroundColor Yellow
		}
		else
		{
			$CloudEmailAddress = $CloudEmailAddress.ToString().ToLower().Replace('smtp:', '')
		}
			
		$UserInfo | Add-Member -Type NoteProperty -Name LegacyExchangeDN -Value $user.LegacyExchangeDN	
		$UserInfo | Add-Member -Type NoteProperty -Name CloudEmailAddress -Value $CloudEmailAddress
		$UserInfo | Add-Member -Type NoteProperty -Name OnPremiseEmailAddress -Value $user.PrimarySMTPAddress.ToString()
		$UserInfo | Add-Member -Type NoteProperty -Name MailboxGUID -Value $user.ExchangeGUID	

		$Users += $UserInfo
	}

	#Check for existing csv file and overwrite if needed
	if(Test-Path ".\cloud.csv")
	{
		$delete = Read-Host "The file cloud.csv already exists in the current directory.  Do you want to delete it?  Enter y to delete, anything else to exit this script."
		if($delete.ToString().ToLower() -eq 'y')
		{
			Write-Host "Deleting existing cloud.csv file" -ForeGroundColor Red
			Remove-Item ".\cloud.csv"
		}
		else
		{
			Write-Host "Will NOT delete current cloud.csv file.  Exiting script." -ForeGroundColor Green
			Exit
		}
	}
	$Users | Export-CSV -Path ".\cloud.csv" -notype
	(Get-Content ".\cloud.csv") | %{$_ -replace '"', ''} | Set-Content ".\cloud.csv" -Encoding Unicode
	Write-Host "CSV File Successfully Exported to cloud.csv" -ForeGroundColor Green

}

O365Logon
Main


