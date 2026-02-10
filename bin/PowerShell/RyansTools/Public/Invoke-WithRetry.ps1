class InvokeWithRetryResult {
	#PSTypeName = "InvokeWithRetryResult"
	[Bool]$IsSuccessful
	[Object]$Value
	[System.Management.Automation.ErrorRecord[]]$Errors
}

Function Invoke-WithRetry() {
	[CmdletBinding()]
	[OutputType([InvokeWithRetryResult])]
	param (
		[Parameter(Mandatory = $true)][String]$retryScript,
		[Array]$argumentList,
		[Parameter(Mandatory = $true)][Int]$maxRetry,
		[Parameter(Mandatory = $true)][String]$logMessage,
		[Parameter(Mandatory = $true)][String]$failureMessage,
		[Parameter(Mandatory = $false)][Bool]$noThrow
	)

	$result = New-Object InvokeWithRetryResult;
	$result.Errors = @();

	$retry = 1;
	$errorMsg;
	while ($retry -le $maxRetry) {
		Write-Verbose "Attempt ${retry}: $logMessage";
		try {
			$script = [ScriptBlock]::Create($retryScript)
			$result.Value = Invoke-Command -ScriptBlock $script -ArgumentList $argumentList -NoNewScope
			$result.IsSuccessful = $true;
			return $result;
		} 
		catch {
			$result.Errors += $_;
			Write-Error $_.Exception | Format-Table
			if ($retry -ge $maxRetry) {
				$result.IsSuccessful = $false;
				Write-Error $failureMessage
				if ($noThrow -eq $false) {
					throw $failureMessage;
				}
			}
		}
		$retry++;
	}
}