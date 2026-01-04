function Get-UserHomeFolderInfo {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string] $HomeRootPath
    )

    BEGIN {}

    PROCESS {
        Write-Verbose "Enumerating $HomeRootPath"
        $params = @{
            'Path'      = $HomeRootPath
            'Directory' = $true
        }

        foreach ($folder in (Get-childitem @params)) {
            write-verbose "Checking $(folder.name)"
            $params = @{
                'Identity'    = $folder.Name
                'ErrorAction' = 'SilentlyContinue'
            }
            $user = get-aduser @params

            if ($user) {
                Write-Verbose " + User Exists."
                $result = get-foldersize -Path $folder.fullname
                [PSCustomObject]@{
                    'user'   = $folder.Name
                    'Path'   = $folder.fullname
                    'Files'  = $result.Files
                    'Bytes'  = $result.Bytes
                    'Status' = 'OK'
                }
            }
            else {
                Write-verbose " - User does not exist."
                [PSCustomObject]@{
                    'user'   = $folder.Name
                    'Path'   = $folder.fullname
                    'Files'  = 0
                    'Bytes'  = 0
                    'Status' = 'Orphan'
                }
            }
        }
    }

    END {}
}