Import-Module nanoserverimagegenerator.psm1

# Nano Server Packages for Image
$NanoPackages = "Microsoft-NanoServer-Compute-Package",
"Microsoft-NanoServer-DCB-Package",
"Microsoft-NanoServer-DSC-Package",
"Microsoft-NanoServer-FailoverCluster-Package",
"Microsoft-NanoServer-OEM-Drivers-Package",
"Microsoft-NanoServer-Storage-Package"
$ServicingPackagePath = ".\Updates\Windows10.0-KB3176936-x64.cab", ".\Updates\Windows10.0-KB3176936-x64.cab"
$UnattanedXML = ".\XMLs\unattend.xml"
$MaxSize = 20GB
$Edition = "Standard"
$TargetPath = "c:\Images\"
$DeploymentType = "Guest"
$DriverPath = ".\Drivers"
$MediaPath = "E:"
$WorkingPath = "C:\nano_workingdir"
$BasePath = ".\Base"
$AdministratorPassword = "ASDqwe123"
$ComputerName = "NanoSrv01"
$DomainName = "ad.geekyryan.com"

#IP Configuration if not DHCP
#$Ipv4Address = "172.21.22.101"
#$Ipv4SubnetMask = "255.255.255.0"
#$Ipv4Gateway = "172.21.22.1"
#$Ipv4Dns = "8.8.8.8"
# Nano Image
#New-NanoServerImage -MediaPath $MediaPath -BasePath $BasePath -TargetPath $VHDXName -DeploymentType $DeploymentType -Edition $Edition -ComputerName $ComputerName

New-NanoServerImage -DeploymentType $DeploymentType -Edition $Edition -MediaPath $MediaPath -BasePath $WorkingPath -TargetPath $TargetPath\$ComputerName.vhdx -Defender -ComputerName $ComputerName -AdministratorPassword ($AdministratorPassword | Convertto-SecureString -asplaintext -force) -EnableRemoteManagementPort
