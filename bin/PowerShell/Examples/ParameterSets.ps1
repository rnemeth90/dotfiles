Param(

  [Parameter(Position=0,

      Mandatory=$True,

      ValueFromPipeline=$True)]

  [string]$userName,

  [Parameter(Position=1,

      Mandatory=$True,

      ValueFromPipeline=$True)]

  [string]$GroupName,

  [string]$computerName = $env:ComputerName,

  [Parameter(ParameterSetName=’addUser’)]

  [switch]$add,

  [Parameter(ParameterSetName=’removeuser’)]

  [switch]$remove

 )