<#
    .SYNOPSIS
    Get's various facts about an SSL cert bound to a website
    .PARAMETER DomainName
    The domain name to connect to.
    .PARAMETER Port
    The port to connect to. 443 by default
    .EXAMPLE
    Get-WebsiteCertificate -DomainName www.bobsdonuts.com
    .EXAMPLE
    Get-WebsiteCertificate -DomainName www.bobsdonuts.com -Port 4433
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.1
#>

function Get-WebsiteCertificate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DomainName,
        [Parameter(Mandatory = $false)]
        [int]$Port = 443
    )

    begin {}

    process {
        $Certificate = $null
        $results = $()
        $TcpClient = New-Object -TypeName System.Net.Sockets.TcpClient

        try {
            try {
                $TcpClient.Connect($DomainName, $Port)
            }
            catch {
                Write-Host "[FAIL] $DomainName" -ForegroundColor Red
            }

            if ($TcpClient.Connected -eq $true) {
                $TcpStream = $TcpClient.GetStream()
                $Callback = { param($sender, $cert, $chain, $errors) return $true }
                $SslStream = New-Object -TypeName System.Net.Security.SslStream -ArgumentList @($TcpStream, $true, $Callback)
                $IpAddress = (Resolve-DnsName $DomainName -Type A -ErrorAction SilentlyContinue).IpAddress

                try {

                    $SslStream.AuthenticateAsClient('')
                    $Certificate = $SslStream.RemoteCertificate

                    if ($Certificate) {

                        if ($Certificate -isnot [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
                            $Certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $Certificate
                        }

                        $details = [PSCustomObject]@{
                            HostName    = $DomainName
                            IPAddress   = $IpAddress
                            DnsNameList = $Certificate.DnsNameList
                            NotAfter    = $Certificate.NotAfter
                            NotBefore   = $Certificate.NotBefore
                            ThumbPrint  = $Certificate.ThumbPrint
                            Issuer      = $Certificate.Issuer
                            Subject     = $Certificate.Subject
                        }
                    }
                    $results += $details
                }
                finally {
                    $SslStream.Dispose()
                }
            }
        }
        finally {
            $TcpClient.Dispose()
        }
        return $results
    }
    end {}
}