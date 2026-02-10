
az login
az account set -s prod-ECIDNS-PAUG-sub-01
az group create -n rg_prod_dns_vibehcm_com -l centralus
az network dns zone import -g rg_prod_dns_vibehcm_com -n VibeHCM.com -f vibehcm.com.zonefile.txt

#az network dns record-set list myresourcegroup contoso.com

#az network dns record-set show --resource-group contosoRG --zone-name contoso.net --type NS --name @
