
$title="SKUs for location: " + `
$locname.DisplayName + `
", Publisher: " + `
$pubname.PublisherName + `
", Offer: " + `
$offername.Offer
 
Get-AzVMImageSku `
-Location $locname.DisplayName `
-PublisherName $pubname.PublisherName `
-Offer $offername.Offer | `
select SKUS | `
Out-GridView -Title $title