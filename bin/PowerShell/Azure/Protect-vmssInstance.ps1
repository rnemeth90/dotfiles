#Get the instanceId of newest instance
$instanceId

#protect the instance
$ProtectFromScaleIn = $false


Update-AzVmssVM `
  -ResourceGroupName "prod-rg-us-nc-hcm-02" `
  -VMScaleSetName "prod-ss-us-nc-hcm-02" `
  -InstanceId $instanceId `
  -ProtectFromScaleIn $ProtectFromScaleIn `
  -ProtectFromScaleSetAction $true