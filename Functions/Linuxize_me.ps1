Set-PSReadLineOption -EditMode Emacs
Set-Alias time Measure-Command

# Like Unix touch, creates new files and updates time on old ones
# PSCX has a touch, but it doesn't make empty files
#Remove-Alias touch
function touch($file) {
  if ( Test-Path $file ) {
    Set-FileTime $file
  }
  else {
    New-Item $file -type file
  }
}

# WATCH
function watch {
  param (
    [Parameter(Mandatory = $true)]
    [string]$command,
    [Parameter(Mandatory = $true)]
    [int]$n
  )

  Watch-Command -Seconds $n -ScriptBlock { $command }
}

# HEAD
function head {
  param (
    [Parameter(Mandatory = $true)]
    [string]$file
  )
  Get-Content $file | Select-Object -last 10
}


### NEEDS SOME WORK
# WC
# function wc {
# 	param (
# 		[Parameter(Mandatory=$false)]
# 		[string]$file
# 	)
# 	if(!$file)
# 	{
# 		Measure-Object -InputObject $_ -Line
# 	}
# 	else{
# 		Get-Content $file | Measure-Object -Line
# 	}

# }

# LN
function ln($target, $link) {
  New-Item -ItemType SymbolicLink -Path $link -Value $target
}
set-alias new-link ln

# EXPORT
function export($name, $value) {
  set-item -force -path "env:$name" -value $value;
}

# PKILL
function pkill($name) {
  get-process $name -ErrorAction SilentlyContinue | stop-process
}

# PGREP
function pgrep($name) {
  get-process $name
}

# FUSER
function fuser($relativeFile) {
  $file = Resolve-Path $relativeFile
  write-output "Looking for processes using $file"
  foreach ( $Process in (Get-Process)) {
    foreach ( $Module in $Process.Modules) {
      if ( $Module.FileName -like "$file*" ) {
        $Process
      }
    }
  }
}

# UPTIME
function uptime {
  $bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
  $currentTime = Get-Date
	($uptime = $currentTime - $bootuptime) | Select-Object Hours, Minutes, Seconds
  # Get-CimInstance Win32_OperatingSystem | Select-Object csname, @{LABEL='LastBootUpTime';
  # EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

# DF
function df {
  get-volume
}

# grep
function grep($regex, $dir) {
  if ( $dir ) {
    get-childitem $dir | Select-String $regex
    return
  }
  $input | Select-String $regex
}

# grepv
function grepv($regex) {
  $input | where-object { !$_.Contains($regex) }
}

# which
function which($name) {
  Get-Command $name | Select-Object-Object-Object -ExpandProperty Definition
}

# cut
function cut() {
  foreach ($part in $input) {
    $line = $part.ToString();
    $MaxLength = [System.Math]::Min(200, $line.Length)
    $line.subString(0, $MaxLength)
  }
}

# sudo, this needs some work...
function sudo() {
  if ($args.Length -eq 1) {
    start-process $args[0] -verb "runAs"
  }
  if ($args.Length -gt 1) {
    start-process $args[0] -ArgumentList $args[1..$args.Length] -verb "runAs"
  }
}

# pstree
function pstree {
  $ProcessesById = @{}
  foreach ($Process in (Get-CimInstance -Class Win32_Process)) {
    $ProcessesById[$Process.ProcessId] = $Process
  }

  $ProcessesWithoutParents = @()
  $ProcessesByParent = @{}
  foreach ($Pair in $ProcessesById.GetEnumerator()) {
    $Process = $Pair.Value

    if (($Process.ParentProcessId -eq 0) -or !$ProcessesById.ContainsKey($Process.ParentProcessId)) {
      $ProcessesWithoutParents += $Process
      continue
    }

    if (!$ProcessesByParent.ContainsKey($Process.ParentProcessId)) {
      $ProcessesByParent[$Process.ParentProcessId] = @()
    }
    $Siblings = $ProcessesByParent[$Process.ParentProcessId]
    $Siblings += $Process
    $ProcessesByParent[$Process.ParentProcessId] = $Siblings
  }

  function Show-ProcessTree([UInt32]$ProcessId, $IndentLevel) {
    $Process = $ProcessesById[$ProcessId]
    $Indent = " " * $IndentLevel
    if ($Process.CommandLine) {
      $Description = $Process.CommandLine
    }
    else {
      $Description = $Process.Caption
    }

    Write-Output ("{0,6}{1} {2}" -f $Process.ProcessId, $Indent, $Description)
    foreach ($Child in ($ProcessesByParent[$ProcessId] | Sort-Object CreationDate)) {
      Show-ProcessTree $Child.ProcessId ($IndentLevel + 4)
    }
  }

  Write-Output ("{0,6} {1}" -f "PID", "Command Line")
  Write-Output ("{0,6} {1}" -f "---", "------------")

  foreach ($Process in ($ProcessesWithoutParents | Sort-Object CreationDate)) {
    Show-ProcessTree $Process.ProcessId 0
  }
}

# reboot
function reboot {
  shutdown /r /t 0
}

function shutdown {
  shutdown /s /f /t 0
}