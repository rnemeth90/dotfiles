Import-Module ADDSDeployment
Install-ADDSDomainController `
-NoGlobalCatalog:$false `
-InstallDns:$true `
-CreateDnsDelegation:$false `
-CriticalReplicationOnly:$false `
-DatabasePath "C:\Windows\NTDS" `
-LogPath "C:\Windows\NTDS" `
-SysvolPath "C:\Windows\SYSVOL" `
-DomainName "ecimain.ecipay.com" `
-NoRebootOnCompletion:$false `
-SiteName "Azure" `
-Force:$true