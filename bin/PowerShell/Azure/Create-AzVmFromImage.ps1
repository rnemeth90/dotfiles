[CmdletBinding()]
param (
    # Name of the image to use as reference
    [Parameter(Mandatory=$true)]
    [String]$ImageName,
    # Name of the virtual machine to be created
    [Parameter(Mandatory=$true)]
    [String]$VmName,
    # Name of the resource group to create for the VM
    [Parameter(Mandatory=$true)]
    [String]$ResourceGroup,
    # Location to create the resources in
    [Parameter(Mandatory=$true)]
    [String]$Location,
    # Name of the subnet to create the VM in
    [Parameter(Mandatory=$true)]
    [String]$SubnetName
)

$vmSize = "Standard_D1_v2"
$vnetName = "prod-vn-us-nc-vnet-01"

# get the image and store it
$imageRef = Get-AzImage -ImageName $ImageName
$osType = (Get-AzImage -ImageName $ImageName).StorageProfile.OsDisk.OsType
$subnetId = (Get-AzVirtualNetwork -Name $vnetName | Get-AzVirtualNetworkSubnetConfig -name $subnetName).id
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

if (!(Get-AzResourceGroup -Name $ResourceGroup)){
    Write-Host "Creating resource group " +$resourceGroup+ " in " +$location+ "..."
    New-AzResourceGroup -Name $ResourceGroup -Location $Location
}

# Create a virtual machine
if(!(Get-AzVM -Name $VmName)){
    try {
        Write-Host "Creating the VM. This may take a bit..." -ForegroundColor Green
        $nic = New-AzNetworkInterface -Name $VmName+"nic" `
        -ResourceGroupName $ResourceGroup `
        -Location $location `
        -SubnetId $subnetId

        $vmConfig = New-AzVMConfig `
            -VMName $VmName `
            -VMSize $vmSize| `
            Set-AzVMOperatingSystem -$osType -ComputerName $VmName -Credential $cred | `
            Set-AzVMSourceImage -Id $imageRef.Id | `
            Add-AzVMNetworkInterface -Id $nic.Id

        New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $vmConfig
    }
    catch {
        Write-Host "An error occurred:"
        Write-Host $_
    }
}
