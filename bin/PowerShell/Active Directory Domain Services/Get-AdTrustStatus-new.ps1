Import-module ActiveDirectory
$Domains = (Get-ADForest).Domains
 
If($? -and $Domains -ne $Null)
{
    ForEach($Domain in $Domains)
    { 
        Write-output "Get list of AD Domain Trusts in $Domain `r"; 
        $ADDomainTrusts = Get-ADObject -Filter {ObjectClass -eq "trustedDomain"} -Server $Domain -Properties * -EA 0
 
        If($? -and $ADDomainTrusts -ne $Null)
        {
            If($ADDomainTrusts -is [array])
            {
                [int]$ADDomainTrustsCount = $ADDomainTrusts.Count 
            }
            Else
            {
                [int]$ADDomainTrustsCount = 1
            }
             
            Write-Output "Discovered $ADDomainTrustsCount trusts in $Domain"
             
            ForEach($Trust in $ADDomainTrusts) 
            { 
                $TrustName = $Trust.Name 
                $TrustDescription = $Trust.Description 
                $TrustCreated = $Trust.Created 
                $TrustModified = $Trust.Modified 
                $TrustDirectionNumber = $Trust.TrustDirection
                $TrustTypeNumber = $Trust.TrustType
                $TrustAttributesNumber = $Trust.TrustAttributes
 
                #http://msdn.microsoft.com/en-us/library/cc220955.aspx
                #no values are defined at the above link
                Switch ($TrustTypeNumber) 
                { 
                    1 { $TrustType = "Downlevel (Windows NT domain external)"} 
                    2 { $TrustType = "Uplevel (Active Directory domain - parent-child, root domain, shortcut, external, or forest)"} 
                    3 { $TrustType = "MIT (non-Windows) Kerberos version 5 realm"} 
                    4 { $TrustType = "DCE (Theoretical trust type - DCE refers to Open Group's Distributed Computing Environment specification)"} 
                    Default { $TrustType = $TrustTypeNumber }
                } 
 
                #http://msdn.microsoft.com/en-us/library/cc223779.aspx
                Switch ($TrustAttributesNumber) 
                { 
                    1 { $TrustAttributes = "Non-Transitive"} 
                    2 { $TrustAttributes = "Uplevel clients only (Windows 2000 or newer"} 
                    4 { $TrustAttributes = "Quarantined Domain (External)"} 
                    8 { $TrustAttributes = "Forest Trust"} 
                    16 { $TrustAttributes = "Cross-Organizational Trust (Selective Authentication)"} 
                    32 { $TrustAttributes = "Intra-Forest Trust (trust within the forest)"} 
                    64 { $TrustAttributes = "Inter-Forest Trust (trust with another forest)"} 
                    Default { $TrustAttributes = $TrustAttributesNumber }
                } 
                  
                #http://msdn.microsoft.com/en-us/library/cc223768.aspx
                Switch ($TrustDirectionNumber) 
                { 
                    0 { $TrustDirection = "Disabled (The trust relationship exists but has been disabled)"} 
                    1 { $TrustDirection = "Inbound (TrustING domain)"} 
                    2 { $TrustDirection = "Outbound (TrustED domain)"} 
                    3 { $TrustDirection = "Bidirectional (two-way trust)"} 
                    Default { $TrustDirection = $TrustDirectionNumber }
                }
                        
                Write-output "`tTrust Name: $TrustName `r "
                Write-output "`tTrust Description: $TrustDescription `r "
                Write-output "`tTrust Created: $TrustCreated `r "
                Write-output "`tTrust Modified: $TrustModified  `r "
                Write-output "`tTrust Direction: $TrustDirection `r "
                Write-output "`tTrust Type: $TrustType `r "
                Write-output "`tTrust Attributes: $TrustAttributes `r "
                Write-output " `r "
            }
        }
        ElseIf(!$?)
        {
            #error retrieving domain trusts
            Write-output "Error retrieving domain trusts for $Domain"
        }
        Else
        {
            #no domain trust data
            Write-output "No domain trust data for $Domain"
        }
    } 
}
ElseIf(!$?)
{
    #error retrieving domains
    Write-output "Error retrieving domains"
}
Else
{
    #no domain data
    Write-output "No domain data"
}