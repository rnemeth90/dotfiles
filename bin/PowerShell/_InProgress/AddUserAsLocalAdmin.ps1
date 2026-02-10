
param(
    [Parameter(ParameterSetName='Computer')]
    [string]$Computer=$Env:Computername, #Input Computer Paramter
    [string]$UserPrincipal #Input User Name
)

function Resolve-SamAccount {
param(
    [string]$SamAccount,
    [boolean]$Exit
)
    process {
        try
        {
            $ADResolve = ([adsisearcher]"(samaccountname=$UserPrincipal)").findone().properties['samaccountname'] #Search 
        }
        catch
        {
            $ADResolve = $null
        }

        if (!$ADResolve) {
            Write-Warning "User `'$SamAccount`' not found in AD, please input correct SAM Account"
            if ($Exit) {
                exit
            }
        }
        $ADResolve
    }
}

if (!$UserPrincipal) {
    $UserPrincipal = Read-Host "Please input User Principal"
}

if ($UserPrincipal -notmatch '\\') {
    $ADResolved = (Resolve-SamAccount -SamAccount $UserPrincipal -Exit:$true)
    $UserPrincipal = 'WinNT://',"$env:userdomain",'/',$ADResolved -join ''
} else {
    $ADResolved = ($UserPrincipal -split '\\')[1]
    $DomainResolved = ($UserPrincipal -split '\\')[0]
    $UserPrincipal = 'WinNT://',$DomainResolved,'/',$ADResolved -join ''
}

if (!$InputFile) {
	if (!$Computer) {
		$Computer = Read-Host "Please input computer name"
	}
	[string[]]$Computer = $Computer.Split(',')
	$Computer | ForEach-Object {
		$_
		Write-Host "Adding `'$ADResolved`' to Administrators group on `'$_`'"
		try {
			([ADSI]"WinNT://$_/Administrators,group").add($UserPrincipal)
			Write-Host -ForegroundColor Green "Successfully completed command for `'$ADResolved`' on `'$_`'"
		} catch {
			Write-Warning "$_"
		}	
	}
}
else {
	if (!(Test-Path -Path $InputFile)) {
		Write-Warning "Input file not found, please enter correct path"
		exit
	}
	Get-Content -Path $InputFile | ForEach-Object {
		Write-Host "Adding `'$ADResolved`' to Administrators group on `'$_`'"
		try {
			([ADSI]"WinNT://$_/Administrators,group").add($Trustee)
			Write-Host -ForegroundColor Green "Successfully completed command"
		} catch {
			Write-Warning "$_"
		}        
	}
}
