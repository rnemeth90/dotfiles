Function Get-MachineInfo {
    [CmdletBinding()] # Allows for common parameters of -verbose, -debug, etc
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [Alias('CN', 'MachineName', 'Name')]
        [string[]] $ComputerName, # [string[]] indicates that thsi parameter will accept an array of input values. Hardcoded to local machine
        [string] $LogFailuresToPath,
        [ValidateSet('Wsman', 'Dcom')]
        [string] $Protocol = "wsman", # this hardcodes the protocol to "wsman" unless it is otherwise specified when called
        [switch] $ProtocolFallBack
    )

    BEGIN {}

    PROCESS {
        foreach ($computer in $ComputerName) {
            # Establish session protocol
            if ($Protocol -eq 'Dcom') {
                $option = New-CimSessionOption -Protocol Dcom
            }
            else {
                $option = New-CimSessionOption -Protocol Wsman
            }
            # Connect Session
            $session = New-CimSession -ComputerName $ComputerName -SessionOption $option

            # Query Data
            $os_params = @{'ClassName' = 'Win32_OperatingSystem'
                'CimSession'           = $session
            }
            $os = Get-CimInstance @os_params

            $cs_params = @{'ClassName' = 'Win32_ComputerSystem'
                'CimSession'           = $session
            }
            $cs = Get-CimInstance @cs_params

            $systemDrive = $os.SystemDrive
            $drive_params = @{'ClassName' = 'Win32_LogicalDisk'
                'Filter'                  = "DeviceId='$systemDrive'"
                'CimSession'              = $session
            }
            $drive = Get-CimInstance @drive_params

            $proc_params = @{'ClassName' = 'Win32_Processor'
                'CimSession'             = $session
            }
            $proc = Get-CimInstance @proc_params | Select-Object -First 1

            # Close Session
            Remove-CimSession -CimSession $session

            # Output Data
            $properties = @{'ComputerName' = $computer
                'osVersion'                = $os.Version
                'SPVersion'                = $os.servicepackmajorversion
                'OSBuild'                  = $os.buildnumber
                'Manufacturer'             = $cs.Manufacturer
                'Model'                    = $cs.Model
                'Procs'                    = $cs.numberofprocessors
                'Cores'                    = $cs.numberoflogicalprocessors
                'Ram'                      = ($cs.totalphysicalmemory / 1GB)
                'Architecture'             = $proc.addresswidth
                'SystemDriveFreeSpace'     = $drive.freespace
            }
            $obj = New-Object -TypeName psobject -Property $properties
            Write-output $obj
        }
    }

    END {}
}