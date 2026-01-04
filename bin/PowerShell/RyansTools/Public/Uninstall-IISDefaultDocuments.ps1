Function Uninstall-IISDefaultDocuments {
    <#
    .SYNOPSIS
        This removes the IIS Default Documents from IIS

    .DESCRIPTION
        This removes the IIS Default Documents from IIS		
    #>
    [cmdletbinding()]
    	param (
	)
   process {
   
    $fileNames=@("iisstart.htm")
    foreach($fileName in $fileNames)
    {
        Write-Verbose("Removing $fileName from IISDefaultDocuments")
		remove-webconfigurationproperty /system.webServer/defaultDocument -name files -atElement @{value=$fileName}
     }
  }
}