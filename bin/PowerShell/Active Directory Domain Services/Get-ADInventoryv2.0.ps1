<#
        .SYNOPSIS
        Get-ADInventory.ps1 - PowerShell script to collect Active Directory information
        .DESCRIPTION 
        This PowerShell Script collects various information about an Active Directory 
        environment like Sites, Forest and Domain Mode, Global Catalogs.
        All information is saved in an HTML file that can be used as inventory file 
        or useful for verifying pre-requites for deployments or upgrade that rely
        on specific Active Directory version.
        .OUTPUTS
        Results are output to an HTML
        .EXAMPLE
        .\Get-ADInventory.ps1
        Runs the script and generates the output.
        .NOTES
        Written by: Daniele Catanesi
        Find me on:
        * My Blog:	http://blog.helocheck.com
        * Twitter:	https://twitter.com/helocheck
        * LinkedIn:	http://ch.linkedin.com/in/catanesi
        Change Log
        v1.0, 22/01/2016 - Initial version
        v1.1, 24/01/2016 - Corrected issue with custom PSObject initialization
        v2.0  21/10/2016 - Corrected an issue with report and other minor typos
#>

#requires -Version 2

# Set all variables to $null to clear any previous run
$htmlBody = $null
$adForest = $null

# Variables to control HTML formatting
$htmlBr = '</br>'
$reportDate = (Get-Date -Format dd.MM.yyyy)

# Configure HTML report path to current script directory
$htmlReportPath = [System.IO.Directory]::GetCurrentDirectory()
$htmlReportFile = "$(Get-Date -Format yyyyMMdd)-ADInventory.html"

# Load AD module if not already loaded
if (!(Get-Module -Name ActiveDirectory))
{
	Import-Module -Name ActiveDirectory
}

#---------------------------------------------------------------------
# Custom PSobjects definition used to gather and store information
#---------------------------------------------------------------------

# Create new custom object to store gathered information
$adForestInfo = New-Object -TypeName PsObject
$adSiteInfo = New-Object -TypeName PsObject
$adFsmo = New-Object -TypeName PsObject
$adDomainInfo = New-Object -TypeName PsObject
$adDomainFsmo = New-Object -TypeName PsObject

#---------------------------------------------------------------------
# Collect AD Forest information
#---------------------------------------------------------------------

# Store Forest Domain Name
$adForest = Get-ADForest
$adsites = Get-ADReplicationSite -Filter *

# Create secion for forest information
$htmlBody += '<h3>Forest Details</h3>'

$adForestInfo | Add-Member -MemberType NoteProperty -Name 'Forest Name' -Value $($adForest.Name)
$adForestInfo | Add-Member -MemberType NoteProperty -Name 'Forest Mode' -Value $($adForest.ForestMode)
$htmlBody += $adForestInfo | ConvertTo-Html -Fragment

# Create section for Forest FSMO Roles
$htmlBody += '<h3>Forest FSMO Roles Information</h1>'

$adFsmo | Add-Member -MemberType NoteProperty -Name 'Schema Master' -Value $($adForest.SchemaMaster)
$adFsmo | Add-Member -MemberType NoteProperty -Name 'Domain Naming Master' -Value $($adForest.DomainNamingMaster)
$htmlBody += $adFsmo | ConvertTo-Html -Fragment

#---------------------------------------------------------------------
# Collect Global Catalog Servers information
#---------------------------------------------------------------------

# Create secion for Global Catalog information
$htmlBody += '<h3>Global Catalog Servers by Site</h3>'

# Query all Global Catalog Servers
$adGlobalCatalog = @(Get-ADDomainController -Filter {
		IsGlobalCatalog -eq $true
	})

# Sort Global Catalogs per Site Name and Operating System
$adGC = @($adGlobalCatalog |
	Group-Object -Property:Site, OperatingSystem |
	Select-Object -Property @{
		Expression = 'Name'
		Label = 'Site, OS'
	}, Count)

# Format Output for proper HTML rendering
$adGC = $adGC | Sort-Object -Property 'Site, OS'
$null = $adGC |
Format-Table -AutoSize

$htmlBody += $adGC | ConvertTo-Html -Fragment
$htmlBody += $htmlBr

#---------------------------------------------------------------------
# Collect Domains information
#---------------------------------------------------------------------

# Store all domains information
$adDomains = @($adForest.Domains)

# Cycle through domains and add necessary properties
foreach ($domain in $adDomains)
{
	$htmlBody += "<h3>Domain Details for $domain Domain</h3>"
	
	$adDomainInfo = New-Object -TypeName PsObject
	$adDomainFsmo = New-Object -TypeName PsObject
	
	$adDomainDetails = Get-ADDomain $domain
	$adDomainInfo | Add-Member -MemberType NoteProperty -Name 'NetBios Name' -Value $($adDomainDetails.NetBIOSName)
	$adDomainInfo | Add-Member -MemberType NoteProperty -Name 'Domain Mode' -Value $($adDomainDetails.DomainMode)
	$adDomainInfo | Add-Member -MemberType NoteProperty -Name 'Domain Controllers' -Value $($adDomainDetails.ReplicaDirectoryServers)
	$adDomainInfo | Add-Member -MemberType NoteProperty -Name 'Read Only Domain Controllers' -Value $($adDomainDetails.ReadOnlyReplicaDirectoryServers)
	
	$adDomainFsmo | Add-Member -MemberType NoteProperty -Name 'Infrastructure Master' -Value $($adDomainDetails.InfrastructureMaster)
	$adDomainFsmo | Add-Member -MemberType NoteProperty -Name 'PDC Emulator' -Value $($adDomainDetails.PDCEmulator)
	$adDomainFsmo | Add-Member -MemberType NoteProperty -Name 'RID Master' -Value $($adDomainDetails.RIDMaster)
	
	Write-Host -Object $(Get-ADDomainController -Filter {
			IsGlobalCatalog -eq $true
		})
	$htmlBody += $adDomainInfo |
	Select "NetBios Name", "Domain Mode", `
		   @{ Name = "Domain Controllers"; Expression = { $_.'Domain Controllers' } }, `
		   @{ Name = "Read Only Domain Controllers"; Expression = { $_."Read Only Domain Controllers" } } |
	ConvertTo-Html -Fragment
	
	$htmlBody += $htmlBr
	
	# Create secion for Child Domains FSMO information
	$htmlBody += '<h3>Child Domain FSMO Roles</h3>'
	$htmlBody += $adDomainFsmo | ConvertTo-Html -Fragment
}

$htmlhead = "<html>     <style>     BODY{font-family: Verdana; font-size: 10pt;}
    H1{font-size: 20px;}
    H2{font-size: 18px;}
    H3{font-size: 16px;}
    TABLE{border: 1px solid black; border-collapse: collapse; font-size: 10pt;}
    TH{border: 1px solid black; background: #99ccff; padding: 5px; color: #000000;}
    TD{border: 1px solid black; padding: 5px; }
    td.pass{background: #7FFF00;}
    td.warn{background: #FFE600;}
    td.fail{background: #FF0000; color: #ffffff;}
    td.info{background: #85D4FF;}
    </style>
    <body>
    <h1 align=""center"">Active Directory Inventory Information</h1>
<h3 align=""center"">Generated: $reportDate</h3>"

# Set html closing tags
$htmltail = '</body> </html>'

# Put everything together in the final report file
$htmlreport = $htmlhead + $htmlBody + $htmltail

# Save report file in HTML Format
$htmlreport | Out-File -FilePath "$htmlReportPath\$htmlReportFile" -Encoding utf8

Write-Host -Object "Report file has been saved to $htmlReportPath\$htmlReportFile" -ForegroundColor Green