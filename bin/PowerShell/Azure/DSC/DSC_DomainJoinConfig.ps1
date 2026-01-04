Configuration DomainJoinConfiguration
{   
    Import-DscResource -ModuleName 'xDSCDomainjoin'
   
    #domain credentials to be given here   
    $secdomainpasswd = ConvertTo-SecureString "YourDomainPassword" -AsPlainText -Force
    $mydomaincreds = New-Object System.Management.Automation.PSCredential                       ("UserName@Domain", $secdomainpasswd)
    $domain = ""
        
    node $AllNodes.NodeName   
    {
        xDSCDomainjoin JoinDomain
        {
            Domain = $domain
            Credential = $mydomaincreds
           
        }
    }
}
