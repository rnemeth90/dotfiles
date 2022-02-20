# From http://stackoverflow.com/questions/7330187/how-to-find-the-windows-version-from-the-powershell-command-line
function get-windows-build {
	[Environment]::OSVersion
}
function disable-windows-search {
	Set-Service wsearch -StartupType disabled
	stop-service wsearch
}
function Set-Hosts {
	sudo notepad "$($env:SystemRoot)\system32\drivers\etc\hosts"
}
set-alias hosts Set-Hosts

function find-file($name) {
	get-childitem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach-object {
		write-output($PSItem.FullName)
	}
}
set-alias find find-file
set-alias find-name find-file

function get-process-for-port($port) {
	Get-Process -Id (Get-NetTCPConnection -LocalPort $port).OwningProcess
}

# From https://serverfault.com/questions/95431/in-a-powershell-script-how-can-i-check-if-im-running-with-administrator-privil#97599
function Test-Administrator  {
	$user = [Security.Principal.WindowsIdentity]::GetCurrent();
	(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function update-powershell-profile {
	. $profile
}
