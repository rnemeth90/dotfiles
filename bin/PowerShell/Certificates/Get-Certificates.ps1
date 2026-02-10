<#
.SYNOPSIS
Get-Certificates.ps1 - Query SSL certs for a list of servers

.DESCRIPTION
This script will query certificates installed on a list of servers.

.OUTPUTS
Results are output to screen.

.PARAMETER ServerList
A list of servers to query in txt file format.

.PARAMETER Detailed
Detailed output. May not look very pretty on screen.

.EXAMPLE
.\Get-Certificates.ps1 -ServerList list.txt
This will query certificates for the given list of servers on port 443 and output to screen.

.EXAMPLE
.\Get-Certificates.ps1 -ServerList list.txt -Detailed
This will query certificates for the given list of servers on port 443 and output detailed results to screen.

.NOTES
Written by: Ryan Nemeth

Find me on:

* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/

Change Log
V1.00, 03/05/2018 - Initial version

TO DO
    - Create logic for scanning a network of servers and pulling cert data
    - Better error handling and recovery
    - Option to output results to file (HTML,CSV)
#>

param(
    #The servers to test in a text file
    [Parameter(Mandatory=$true)]
    [String]$ServerList,
    #Verbose Output
    [Parameter(Mandatory=$False)]
    [Switch]$Detailed
)


#Global Vars
$srvList = Get-Content -Path $ServerList
$ErrorActionPreference = "SilentlyContinue"
$ErrorView = "CategoryView"

#do the work
foreach($srv in $srvList){
    try{
        #Setup connection variables
        $uri = $srv
        $uri.trim()
        $ipaddr = Resolve-DnsName -Name $uri
        $Port = 443
        $Connection = New-Object System.Net.Sockets.TcpClient($ipaddr,$Port)
        $Connection.SendTimeout = 5000
        $Connection.ReceiveTimeout = 5000
        $Stream = $Connection.GetStream()

        #Create object for SSL connection
        #$sslStream = New-Object System.Net.Security.SslStream($Stream, $False, { return $true })
        $sslStream = New-Object System.Net.Security.SslStream($Stream,$False,([Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}))
        $sslStream.AuthenticateAsClient($null)

        #Connect to server and pull cert data, create object for key value
        $cert = $sslStream.get_remotecertificate()
        $key = New-Object system.security.cryptography.x509certificates.x509certificate2($cert)

        #parse cert validity period to dateTime
        $validto = [datetime]::Parse($cert.getexpirationdatestring())
        $validfrom = [datetime]::Parse($cert.geteffectivedatestring())

        #Check if cert is self-signed
        if ($cert.get_issuer().CompareTo($cert.get_subject())) {
            $selfsigned = "No";
        } else {
            $selfsigned = "Yes";
        }

        if ($connection.Connected) {
            $Connection.Close()
        }

        #Out to screen
        if ($Detailed) {
            Write-Host '"' -nonewline; Write-Host "Host:"$uri -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Port:"$Port -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Subject:"$cert.get_subject() -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Issuer:"$cert.get_issuer() -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "KeySize:"$key.PublicKey.Key.KeySize -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "SN:"$cert.getserialnumberstring() -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Issued:" $validfrom -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Expires:" $validto -nonewline; Write-Host '",';
            Write-Host '"' -nonewline; Write-Host "Self-Signed:" $selfsigned -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Algo:"$key.SignatureAlgorithm.FriendlyName -nonewline; Write-Host '"';
        }
        else {
            Write-Host '"' -nonewline; Write-Host "Host:"$uri -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Port:"$Port -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Subject:"$cert.get_subject() -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Issuer:"$cert.get_issuer() -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Issued:"$validfrom -nonewline; Write-Host '",' -nonewline;
            Write-Host '"' -nonewline; Write-Host "Expires:"$validto -nonewline; Write-Host '",';
        }


    }
    catch {
        #Write on error, can't connect to server
        #Write-Host "Cannot connect to $srv on port $port" -ForegroundColor Red
        $_.Exception.Message

    }
    finally {
        #Close the connection
        if ($connection.Connected) {
            $Connection.Close()
        }
    }
}

