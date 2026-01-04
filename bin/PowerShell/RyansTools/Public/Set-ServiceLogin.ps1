Function Set-ServiceLogon {
    <#
    .Synopsis
    Sets service login name and password.
    .Description
    This command uses wither CIM (default) or WMI to set the service password, and optionally the logon user name, for a service, which can be running on one or more remote machines. You must run this command as a user who has permissions to perform this task, remotely, on the computer involved.
    .Parameter ServiceName
    The name of the service. Query the Win32_Service class to verify that you know the correct name.
    .Parameter ComputerName
    One or more computer names. Using IP addresses will fail with CIM; they will work with WMI. CIM is always accepted first.
    .Parameter NewPassword
    A plain test string of the new password
    .Parameter NewUser
    Optional; the new logon user name, in DOMAIN\USER format.
    .Parameter ErrorLogFilePath
    If provided, this is a path and file name of a text file where failed computer names will be logged.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)] # Makes ServiceName mandatory
        [string] $ServiceName,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string] $NewUser,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)] #Password = mandatory
        [string] $NewPassword,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] # Computername = mandatory, accepts pipeline input by value
        [string[]] $ComputerName,
        [string] $ErrorLogFilePath
    )

    Begin {}

    Process {
        foreach ($computer in $ComputerName) {
            do {
                Write-Verbose "Connect to $computer on WS-MAN"
                $protocol = 'Wsman"'

                Try {
                    $option = New-CimSessionOption -Protocol $protocol
                    $session = New-CimSession -ComputerName $computer -SessionOption $option

                    if ($NewUser) {
                        $args = @{'StartName' = "$NewUser"; 'StartPassword' = "$NewPassword" }
                    }
                    else {
                        $args = @{'StartPassword' = "$NewPassword" }
                        Write-warning "Not setting a new user name"
                    }

                    Write-Verbose "Setting $ServiceName on $computer"
                    $cim_params = @{'Query' = "Select * from Win32_Service WHERE Name='$ServiceName'"
                        'MethodName'        = 'Change'
                        'Arguments'         = $args
                        'Computername'      = $computer
                        'CimSession'        = $session
                    }

                    $return = Invoke-CimMethod @cim_params #Splatting

                    switch ($return.ReturnValue) {
                        0 { $status = "Success" }
                        22 { $status = "Invalid Account" }
                        Default { $status = "Failed: $return.ReturnValue" }
                    }

                    $properties = @{'MachineName' = $computer
                        'Status'                  = $status
                    }
                    $object = New-Object -TypeName psobject -Property $properties

                    Write-Verbose "Closing connection to $computer"
                    Write-Output $object

                    $session | Remove-CimSession
                }
                Catch {
                    # change the protocol, and if both have already been tried, check if logging is specified, if so, log the computer
                    Switch ($protocol) {
                        'Wsman' {
                            $protocol = 'Dcom'
                        } 'Dcom' {
                            $protocol = 'Stop'
                            if ($PSBoundParameters.ContainsKey('ErrorLogFilePath')) {
                                Write-Warning "$computer failed; logged to $ErrorLogFilePath."
                                $computer | out-file $ErrorLogFilePath -Append
                            } # IF Logging is enabled
                        }
                    }
                }
            } Until ($protocol -eq 'Stop')
        }
    }
    End {}
}
