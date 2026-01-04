#stop Windows Update Client service
Stop-Service -Name wuauserv -Force

#Remove registry keys
#Remove-ItemProperty -Name "PingID" -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Force
#Remove-ItemProperty -Name "AccountDomainSid" -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Force
Remove-ItemProperty -Name "SusClientId" -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Force
Remove-ItemProperty -Name "SusClientIDValidation" -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Force

#start Windows Update Client service
Start-Service -Name wuauserv 

#Update Group Policy Client Side cache to pull new WSUS settings
gpupdate /force /target:computer

#force Windows Update Client to checkin with WSUS server found in registry
wuauclt.exe /a /detectnow

