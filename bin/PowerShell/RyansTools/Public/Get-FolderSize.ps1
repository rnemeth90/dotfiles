function Get-FolderSize {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $Path
    )

    BEGIN {}
    PROCESS {
        ForEach ($folder in $Path) {
            Write-Verbose "Checking $folder"
            if (Test-Path -Path $folder) {
                Write-Verbose "$folder Exists."

                $params = @{'Path' = $folder
                    'Recurse'      = $true
                    'File'         = $true
                }

                $measure = get-childitem @params | Measure-Object -Property Length -Sum
                [pscustomobject]@{'Path' = $folder
                    'Files'              = $measure.Count
                    'Bytes'              = $measure.Sum
                }
            }
            else {
                Write-Verbose "$folder does not exist."
                [PSCustomObject]@{
                    'Path'  = $folder
                    'Files' = 0
                    'Bytes' = 0
                }
            }
        }
    }
    END {}
}