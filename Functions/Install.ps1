function Install([String]$package, [bool]$beta = $false, [bool]$skipCheckSum = $false) {
  if (-not ((choco list $package --exact --local-only --limitoutput) -like "$package*")) {
    Write-Output "[i] Installing package $package"
    if ($beta) {
      choco install $package -y --pre
    }
    elseif ($skipCheckSum) {
      choco install $package -y --ignore-checksums
    }
    elseif ($beta -And $skipCheckSum) {
      choco install $package -y --pre --ignore-checksums
    }
    else {
      choco install $package -y
    }
  }
  else {
    Write-Output "[i] Package $package already installed"
  }
}
function Uninstall([String]$package) {
  if (((choco list $package --exact --local-only --limitoutput) -like "$package*")) {
    Write-Output "[i] package $package is installed, removing it.."
    choco uninstall $package -y
  }
  else {
    Write-Output "[i] Package $package is already removed, consider removing this uninstall from your bootstrapper"
  }
}