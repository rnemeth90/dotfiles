[CmdletBinding()]
param(
    [ValidateScript({$_ -notmatch "\*"})] 
    [Parameter(ParameterSetName="p1",ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Position=1)] [array] $Title,
    [Parameter(ValueFromPipeline=$true)] [boolean] $Prompt = $true,
    [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Position=0)] [array] $ComputerName = $env:COMPUTERNAME,
    [ValidateScript({Test-Path $_ -PathType Leaf})] 
    [Parameter(ParameterSetName="p2")] [string] $InputFile 
)

Begin {
    Clear-Host
}

Process { 


    Write-Output -Verbose $PsBoundParameters.Values

    function Get-Titles{
        [CmdletBinding(DefaultParametersetName="p1")]
        param(
            [Parameter()] [string[]] $ComputerName,
            [Parameter()] [string[]] $Apps,
            [Parameter()] [string[]] $GUID,
            [parameter()] [switch] $List = $False
        )
        Begin {

        }
    
        Process{
        
            If (!$Apps) {
                $Apps = $GUID
            }

            $Results = @()

            #$scriptblock = {
            Function Get-Registry {
                param(
                    [string] $Computer = $env:COMPUTERNAME,
                    [string[]] $Apps,
                    [string] $Publisher
                )

                    $SomethingsInstalled = $false
                    $ErrorActionPreference = "continue"

                    If ((Get-WmiObject win32_processor -ComputerName $Computer).AddressWidth -eq 32){   
                        Write-Verbose -Verbose "[$(Get-Date)] - [$computer] 32-bit system detected."
                        $keys = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
                        Write-Verbose -Verbose "[$(Get-Date)] - [$computer] Adding 32-bit uninstall '$keys'"
                     } Else {   
                        Write-Verbose -Verbose "[$(Get-Date)] - [$computer] 64-bit system detected, iterating through 32-bit and 64-bit reg keys..."
                        $keys = "SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
                        Write-Verbose -Verbose "[$(Get-Date)] - [$computer] Adding 32/64-bit uninstall '$keys'"
                     }
                    Do {

                        $Reg = ([microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', $Computer))
                        $AppList = $null
                            ForEach ($Title in $Apps) {

                                ForEach ($regitem in $keys) {
                                    $RegKey = $Reg.OpenSubKey($regitem)
                                    $SubKeys = $RegKey.GetSubKeyNames()
                                    $Count = 0

                                    $Data = ForEach ($Key in $SubKeys){   
                                        $thisKey = $regitem + "\\" + $Key
                                        $thisSubKey = $Reg.OpenSubKey($thisKey)

                                        If (($thisSubKey.GetValue("DisplayName") -eq $Title)){
                                            write-verbose -verbose "[$(Get-Date)] - [$computer] Discovered $($thisSubKey.GetValue("DisplayName"))"
                                            $SomethingsInstalled = $true    
                                            $ErrorActionPreference = "SilentlyContinue"
                            
                                            New-Object PSObject -Property @{
                                                Query = "$Title"
                                                Installed = $true
                                                ComputerName = $Computer
                                                UninstallString = $thisSubKey.GetValue("UninstallString")
                                                DisplayName = $thisSubKey.GetValue("DisplayName")
                                                Publisher = $thisSubKey.GetValue("Publisher")
                                                DisplayVersion = $thisSubKey.GetValue("DisplayVersion")
                                                InstallLocation = $thisSubKey.GetValue("InstallLocation")
                                                GUID = $($thisSubKey.GetValue("UninstallString")).Split("{}")[1]
                                            }
                                        } 
                                    }
                               
                                    $Results += $Data
                                    $Data
                                }
                            }

                            If ($SomethingsInstalled -eq $false){
                                $Installed = New-Object PSObject -Property @{
                                    Query = $Title
                                    Installed = $false
                                    ComputerName = $Computer
                                    UninstallString = $null
                                    DisplayName = $null
                                    Publisher = $null
                                    DisplayVersion = $null
                                    InstallLocation = $null
                                    GUID = $null
                                }
                                $Results += $Installed
                            }
                    } 
        
                    Until ($Return -eq $null)

                    $Results
            }

    
            ForEach ($Computer in $ComputerName){
                If (Test-Connection -ComputerName $Computer -Quiet) {

                    ##Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $Computer,$Apps,$List,$Publisher 
                    ####

                    ##Start-Job -Name "$Computer job" -ScriptBlock $Scriptblock -ArgumentList $Computer,$Apps
                
                    Get-Registry -Computer $Computer -Apps $Apps 
            
                } Else {
                    Write-Warning -Verbose "[$(Get-Date)] - [$computer] $Computer appears to be offline.  Skipping..."
                }
            }

            While (@(Get-Job | Where { $_.State -eq "Running" }).Count -ne 0)
            {  Write-Verbose -Verbose "[$(Get-Date)] -  Waiting for background jobs...`r `n"
                ####Clear-Host
                Get-Job    #Just showing all the jobs
                Start-Sleep -Seconds 3
            }
 
            Get-Job       #Just showing all the jobs
            $Data = ForEach ($Job in (Get-Job)) {
                Receive-Job $Job
                Remove-Job $Job
            }

        }

        End {
            $Data
        }
    }

    Function Remove-Titles {
    [CmdletBinding()]
    param(
        [boolean] $Prompt,
        [array] $ComputerName
    )


    If ($Prompt) { 
        Write-Warning -Verbose "[$(Get-Date)] - [$ComputerName] Application(s) installed on $ComputerName`n" 
        Write-Output "Title(s) found on $($ComputerName) :"
        Write-Output $Titles | select Displayname, GUID
    
        $Applications = $Titles.displayname -join ", "
 
        #prompt to let user abort if file sources aren't correct
        #-------------------------------------------------------------
        $title      = "Uninstallation from $($ComputerName) - approval needed"
        $message    = "You've selected the following app(s) for removal on $Computername `n`n $($Applications)`n`n Do you wish to uninstall the application(s) now?"
        $yes        = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Removes application(s) from $computername."
        $no         = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Cancels uninstallation process."
        $options    = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
        $result     = $host.ui.PromptForChoice($title, $message, $options, 0)

        write-output  "`n"
    } Else { 
        #If $prompt is $false, then go ahead and uninstall.  You can imagine how dangerous this could be...
        $result = 0 
    }

        switch ($result) {
            0 {
                Write-Verbose -Verbose "[$(Get-Date)] - [$ComputerName] Performing uninstallation on $ComputerName via MSI."
            }
        }


        If ($result -eq 0){
            ForEach ($App in $Titles){  
            Write-Verbose -Verbose "[$(Get-Date)] - [$ComputerName] Uninstalling $($App.DisplayName) from $ComputerName using GUID: $($App.GUID)"

            $Return = (Get-WmiObject -Class Win32_Product -Filter "IdentifyingNumber='{$($App.GUID)}'" -ComputerName $ComputerName -ErrorAction SilentlyContinue).Uninstall()
                if ($Return.ReturnValue -eq 0){   
                    Write-Verbose -Verbose "[$(Get-Date)] - [$ComputerName] Uninstallation of $($app.displayname) successful!"
                }
                Else {   
                    Write-Error -Verbose "[$(Get-Date)] - [$ComputerName] Uninstallation of $($app.displayname) failed!  Error code: $($Return.ReturnValue)"
                }
            }
        }


    }

    #If we supplied an input file, let's see if we can get some contents and do something with them.
    If ($InputFile) {

        $TitleArray = @() 

        $Entries = Get-Content -Path $InputFile
        ForEach($Entry in $Entries) { 
            $TitleArray += $Entry
        }
    
        ForEach ($Computer in $ComputerName) { 

            $TitleText = $TitleArray -join ";"
            
            Write-Verbose -Verbose "[$(Get-Date)] - [$Computer] Searching for '$TitleText'"

            $Titles = Get-Titles -Apps $TitleArray -ComputerName $Computer | Where-Object {$_.guid -ne $null} | Select-Object DisplayName,GUID -Unique
        
            If ($Titles) {
               Write-Verbose -Verbose "Removing titles..." 
               Remove-Titles -Prompt $Prompt -ComputerName $Computer
            } Else { 
                Write-Verbose -Verbose "[$(Get-Date)] - [$Computer] $Title not found installed on $Computer."
            }
        }
    } Else {
        ForEach ($Computer in $ComputerName) { 
            Write-Verbose -Verbose "[$(Get-Date)] - [$ComputerName] Searching for '$Title'"
        
            $Titles = Get-Titles -Apps $Title -ComputerName $Computer | Where-Object {$_.guid -ne $null} | Select-Object DisplayName,GUID -Unique 
        
            If ($Titles) {
                Remove-Titles -Prompt $Prompt -ComputerName $Computer
            } Else { 
                Write-Verbose -Verbose "[$(Get-Date)] - [$Computer] $Title not discovered."
            }
 
        }
    }
}

End {

}