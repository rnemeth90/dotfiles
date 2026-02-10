Configuration domainJoin
{   
    Import-DscResource -ModuleName 'xDSCDomainjoin'
    $userName = "sa-aa-dsc"
    $domainName = "corp.vibehcm.com"
   
    #domain credentials to be given here   
    $secdomainpasswd = ConvertTo-SecureString "%Yy}>cY`4)em" -AsPlainText -Force
    $mydomaincreds = New-Object System.Management.Automation.PSCredential($userName,$secdomainpasswd)
    #Param ($Server = $env:COMPUTERNAME) 
        
    node $env:COMPUTERNAME 
    {
        xDSCDomainjoin JoinDomain
        {
            Domain = $domainName
            Credential = $mydomaincreds
        }
    }
}