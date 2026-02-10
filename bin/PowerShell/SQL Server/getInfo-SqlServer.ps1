# multiple instance aware function that returns basic information about all instances of SQL installed.
# Version, Edition, fullVer (full version text), majVer, minVer, Build, Arch (bitness, 64-bit or 32-bit), Level (SP/CU), Root (root sql directory), Instance [name]

Param ($SqlServer = $(hostname))

# get instances based on services

$localInstances = @()
[array]$captions = gwmi win32_service -computerName $SqlServer | ?{$_.Name -match "mssql*" -and $_.PathName -match "sqlservr.exe"} | %{$_.Caption}
foreach ($caption in $captions) {
	if ($caption -eq "MSSQLSERVER") {
		$localInstances += "MSSQLSERVER"
	} else {
		$temp = $caption | %{$_.split(" ")[-1]} | %{$_.trimStart("(")} | %{$_.trimEnd(")")}
		$localInstances += $temp
	}
}
# load the SQL SMO assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
	
if ($localInstances.count -gt 1) {
	$SqlInfo = @()
	foreach ($currInstance in $localInstances) {
		if ($currInstance -eq "MSSQLSERVER") {
			$serverName = "$SqlServer"
		} else {
			$serverName = "$SqlServer\$currInstance"
		}
		$server = New-Object -typeName Microsoft.SqlServer.Management.Smo.Server -argumentList "$serverName"
		$tempSqlInfo = "" | Select Version,Edition,fullVer,majVer,minVer,Build,Arch,Level,Root,Instance
		[string]$tempSqlInfo.fullVer = $server.information.VersionString.toString()
		[string]$tempSqlInfo.Edition = $server.information.Edition.toString()
		[int]$tempSqlInfo.majVer = $server.version.Major
		[int]$tempSqlInfo.minVer = $server.version.Minor
		[int]$tempSqlInfo.build = $server.version.Build
		switch ($tempSqlInfo.majVer) {
			8 {[string]$tempSqlInfo.Version = "SQL Server 2000"}
			9 {[string]$tempSqlInfo.Version = "SQL Server 2005"}
			10 {if ($tempSqlInfo.minVer -eq 0 ) {
						[string]$tempSqlInfo.Version = "SQL Server 2008"
					} else {
						[string]$tempSqlInfo.Version = "SQL Server 2008 R2"
					}
				}
			default {[string]$tempSqlInfo.Version = "Unknown"}
		}
		[string]$tempSqlInfo.Arch = $server.information.Platform.toString()
		[string]$tempSqlInfo.Level = $server.information.ProductLevel.toString()
		[string]$tempSqlInfo.Root = $server.information.RootDirectory.toString()
		[string]$tempSqlInfo.Instance = $currInstance
		$SqlInfo += $tempSqlInfo
	}
} else {	
	$server = New-Object -typeName Microsoft.SqlServer.Management.Smo.Server -argumentList "$SqlServer"
	$SqlInfo = "" | Select Version,Edition,fullVer,majVer,minVer,Build,Arch,Level,Root,Instance
	[string]$SqlInfo.fullVer = $server.information.VersionString.toString()
	[string]$SqlInfo.Edition = $server.information.Edition.toString()
	[int]$SqlInfo.majVer = $server.version.Major
	[int]$SqlInfo.minVer = $server.version.Minor
	[int]$SqlInfo.build = $server.version.Build
	switch ($SqlInfo.majVer) {
		8 {[string]$SqlInfo.Version = "SQL Server 2000"}
		9 {[string]$SqlInfo.Version = "SQL Server 2005"}
		10 {if ($SqlInfo.minVer -eq 0 ) {
					[string]$SqlInfo.Version = "SQL Server 2008"
				} else {
					[string]$SqlInfo.Version = "SQL Server 2008 R2"
				}
			}
		default {[string]$SqlInfo.Version = "Unknown"}
	}
	[string]$SqlInfo.Arch = $server.information.Platform.toString()
	[string]$SqlInfo.Level = $server.information.ProductLevel.toString()
	[string]$SqlInfo.Root = $server.information.RootDirectory.toString()
	[string]$SqlInfo.Instance = $localInstances[0]
}
return $SqlInfo
