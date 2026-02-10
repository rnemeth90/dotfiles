<#
    .SYNOPSIS 
     Creates the necessary settings to establish a site to site VPN between your local environment and Windows Azure
    .PARAMETER Mode
     This script does not currently accept parameters. 
    .EXAMPLE
     Create-AzureS2sVpn.ps1
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
    .EXAMPLE
     Create-AzureS2sVpn.ps1
#>


#Login-AzureRmAccount
#Get-AzureRmSubscription
#Select-AzureRmSubscription -SubscriptionName "Replace with subscription you would like to use"


$AzureRmResourceGroupName = ""
$AzureRmResourceGroupLocation = ""
$AzureRmVirtualSubnetName1 = ""
$AzureRmVirtualSubnetPrefix1 = "GatewaySubnet"
$AzureRmVirtualSubnetName2 = ""
$AzureRmVirtualSubnetPrefix2 = ""
$AzureRmVirtualNetworkName = ""
$AzureRmVirtualNetworkPrefix = ""
$LocalNetworkGatewayIpAddress = ""
$LocalNetworkGatewaySubnet = ""
$LocalNetworkGatewayName = ""
$AzureNetworkGatewayName = ""
$GatewayType = 'VPN'
$VpnType = 'PolicyBased'
$gatewaySku = 'Basic' 
$AzurePublicIpName = 'AzurePublicIp1'
$VpnConnectionName = "EdisonLakes-Azure"
$SharedKey = "w2YmYqEq6z7H3fU3"
$VpnConnectionType = 'IpSec'



###########################################################################################

#Create a virtual network and a gateway subnet
New-AzureRmResourceGroup -Name $AzureRmResourceGroupName -Location $AzureRmResourceGroupLocation
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name $AzureRmVirtualSubnetName1 -AddressPrefix $AzureRmVirtualSubnetPrefix1
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name $AzureRmVirtualSubnetPrefix2 -AddressPrefix $AzureRmVirtualSubnetPrefix2
New-AzureRmVirtualNetwork -Name $AzureRmVirtualNetworkName -ResourceGroupName $AzureRmResourceGroupName -Location $AzureRmResourceGroupLocation -AddressPrefix $AzureRmVirtualNetworkPrefix -Subnet $subnet1, $subnet2

#OR

#Add a gateway subnet to an existing virtual network
#$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName testrg -Name testvnet
#Add-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix 10.0.3.0/28 -VirtualNetwork $vnet
#Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

###########################################################################################

#Add your local network gateway
#In a virtual network, the local network gateway typically refers to your on-premises location. You'll give that site a name by which Azure can refer to it, 
#and also specify the address space prefix for the local network gateway.

New-AzureRmLocalNetworkGateway -Name $LocalNetworkGatewayName -ResourceGroupName $AzureRmResourceGroupName -Location $AzureRmResourceGroupLocation -GatewayIpAddress $LocalNetworkGatewayIpAddress -AddressPrefix $LocalNetworkGatewayIpAddress `
-ErrorAction Continue -ErrorVariable $Errors

#OR

#Add a local network gateway with multiple prefixes
#New-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName $AzureRmResourceGroupName -Location $AzureRmResourceGroupLocation -GatewayIpAddress '23.99.221.164' -AddressPrefix @('10.0.0.0/24','20.0.0.0/24')

###########################################################################################

#Request a public IP address for the VPN gateway
$AzureGatewayIp= New-AzureRmPublicIpAddress -Name $AzurePublicIpName -ResourceGroupName $AzureRmResourceGroupName -Location $AzureRmResourceGroupLocation -AllocationMethod Dynamic

###########################################################################################
#Create the gateway IP addressing configuration
$vnet = Get-AzureRmVirtualNetwork -Name $AzureRmVirtualNetworkName -ResourceGroupName $AzureRmResourceGroupName
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$gwipconfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name gwipconfig1 -SubnetId $subnet.Id -PublicIpAddressId $AzureGatewayIp.Id 


###########################################################################################
#create the virtual network gateway
New-AzureRmVirtualNetworkGateway -Name $AzureNetworkGatewayName -ResourceGroupName $AzureRmResourceGroupName -Location $AzureRmResourceGroupLocation -IpConfigurations $gwipconfig -GatewayType $GatewayType -VpnType $VpnType -GatewaySku $gatewaySku


###########################################################################################
#At this point, you'll need the public IP address of the virtual network gateway for configuring your on-premises VPN device. 
#Work with your device manufacturer for specific configuration information. Additionally, refer to the VPN Devices for more information.
#To find the public IP address of your virtual network gateway, use the following sample:

Get-AzureRmPublicIpAddress -Name $AzurePublicIpName -ResourceGroupName $AzureRmResourceGroupName

Write-Host "Using the Public IP Address above, please configure your local VPN Gateway device"
Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

###########################################################################################
#Create the vpn connection
$gateway1 = Get-AzureRmVirtualNetworkGateway -Name $AzureNetworkGatewayName -ResourceGroupName $AzureRmResourceGroupName
$local = Get-AzureRmLocalNetworkGateway -Name $LocalNetworkGatewayName -ResourceGroupName $AzureRmResourceGroupName

New-AzureRmVirtualNetworkGatewayConnection -Name $VpnConnectionName -ResourceGroupName $AzureRmResourceGroupName -Location $AzureRmResourceGroupLocation -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local -ConnectionType $VpnConnectionType -RoutingWeight 10 -SharedKey $SharedKey

###########################################################################################
#Verify the VPN Connection
Get-AzureRmVirtualNetworkGatewayConnection -Name $VpnConnectionName -ResourceGroupName $AzureRmResourceGroupName -Debug
