$sas = @("intsausncasr08",
"intsausncasr09",
"intsausncasr10",
"intsausncasr11")

$rg = "int-rg-us-nc-asr-01"
$location = "northcentralus"
$sku = "standard_grs"

foreach ($sa in $sas) {
    New-AzureRmStorageAccount -ResourceGroupName $rg -Name $sa -Location $location -SkuName $sku
}
