#The Configuration Name - Part 1
Configuration ADDS
{
    #Parameters - Part 2
    # The server to deploy to
    Param ($Server = $env:COMPUTERNAME) 
    
    #The servers to configure - Part 3
    Node $Server
    {
        #The DSC Resource - Part 4 
        WindowsFeature ActiveDirectory 
        {
            Name = "Ad-Domain-Services"
            Ensure = "Present"
        }

        WindowsFeature DNS
        {
            Name = "DNS"
            Ensure = "Present"
        }
    }
}