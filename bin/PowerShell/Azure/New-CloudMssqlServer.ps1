$ResourceGroupName = ""
$Location = ""
$VMName = ""
$VNET = "prod-vn-us-nc-vnet-01"
$VMSize = ""

#Load Azure 
Connect-AzAccount

#Create Resource Resource
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

#Configure networking for the VM
$Network = Get-AzVirtualNetwork -Name $vnet
$InterfaceName = $VMName + Get-Random
$Interface = New-AzNetworkInterface -Name $InterfaceName `
   -ResourceGroupName $ResourceGroupName -Location $Location `
   -SubnetId $Network.Subnets[0].Id


#Create the VM
$VMConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize | `
   Set-AzVMOperatingSystem -Windows -ComputerName $VMName -Credential $Cred -ProvisionVMAgent -EnableAutoUpdate | `
   Set-AzVMSourceImage -PublisherName "MicrosoftSQLServer" -Offer "SQL2017-WS2016" -Skus "SQLDEV" -Version "latest" | `
   Add-AzVMNetworkInterface -Id $Interface.Id

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VMConfig



#Install the SQL IaaS Agent
Set-AzVMSqlServerExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -name "SQLIaasExtension" -version "1.2" -Location $Location

#Sleep while the agent installs
Start-Sleep -Seconds 1200

#Stop the VM
Stop-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName
