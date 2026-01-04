<#-----------------------------------------------------------------------------
How to find AD schema update history using PowerShell

This script reports on schema update and version history for Active Directory.
It requires the ActiveDirectory module to run (Windows 7 or Windows Server
2008 R2 with RSAT).
It makes no changes to the environment.


----------------------------------------------------------------------------#>
## INCREASE WINDOW WIDTH #####################################################
function WidenWindow([int]$preferredWidth)
{
  [int]$maxAllowedWindowWidth = $host.ui.rawui.MaxPhysicalWindowSize.Width
  if ($preferredWidth -lt $maxAllowedWindowWidth)
  {
    # first, buffer size has to be set to windowsize or more
    # this operation does not usually fail
    $current=$host.ui.rawui.BufferSize
    $bufferWidth = $current.width
    if ($bufferWidth -lt $preferredWidth)
    {
      $current.width=$preferredWidth
      $host.ui.rawui.BufferSize=$current
    }
    # else not setting BufferSize as it is already larger
    
    # setting window size. As we are well within max limit, it won't throw exception.
    $current=$host.ui.rawui.WindowSize
    if ($current.width -lt $preferredWidth)
    {
      $current.width=$preferredWidth
      $host.ui.rawui.WindowSize=$current
    }
    #else not setting WindowSize as it is already larger
  }
}

WidenWindow(120)
$a = "<style>"
$a = $a + "BODY{background-color:ltgrey;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:PaleGoldenrod}"
$a = $a + "</style>"



Import-Module ActiveDirectory 

$schema = Get-ADObject -SearchBase ((Get-ADRootDSE).schemaNamingContext) `
    -SearchScope OneLevel -Filter * -Property objectClass, name, whenChanged,`
    whenCreated | Select-Object objectClass, name, whenCreated, whenChanged, `
    @{name="event";expression={($_.whenCreated).Date.ToShortDateString()}} | `
    Sort-Object whenCreated

"`nDetails of schema objects created by date:"
$schema | Format-Table objectClass, name, whenCreated, whenChanged `
    -GroupBy event -AutoSize

"`nCount of schema objects created by date:"
$schema | Group-Object event | Format-Table Count, Name, Group -AutoSize

#------------------------------------------------------------------------------

"`nForest domain creation dates:"
Get-ADObject -SearchBase (Get-ADForest).PartitionsContainer `
    -LDAPFilter "(&(objectClass=crossRef)(systemFlags=3))" `
    -Property dnsRoot, nETBIOSName, whenCreated |
  Sort-Object whenCreated |
  Format-Table dnsRoot, nETBIOSName, whenCreated -AutoSize

#------------------------------------------------------------------------------

$SchemaVersions = @()

$SchemaHashAD = @{
    13="Windows 2000 Server";
    30="Windows Server 2003";
    31="Windows Server 2003 R2";
    44="Windows Server 2008";
    47="Windows Server 2008 R2"
    }

$SchemaPartition = (Get-ADRootDSE).NamingContexts | Where-Object {$_ -like "*Schema*"}
$SchemaVersionAD = (Get-ADObject $SchemaPartition -Property objectVersion).objectVersion
$SchemaVersions += 1 | Select-Object `
    @{name="Product";expression={"AD"}}, `
    @{name="Schema";expression={$SchemaVersionAD}}, `
    @{name="Version";expression={$SchemaHashAD.Item($SchemaVersionAD)}}

#------------------------------------------------------------------------------

$SchemaHashExchange = @{
    4397="Exchange Server 2000 RTM";
    4406="Exchange Server 2000 SP3";
    6870="Exchange Server 2003 RTM";
    6936="Exchange Server 2003 SP3";
    10628="Exchange Server 2007 RTM";
    10637="Exchange Server 2007 RTM";
    11116="Exchange 2007 SP1";
    14622="Exchange 2007 SP2 or Exchange 2010 RTM";
    14625="Exchange 2007 SP3";
    14726="Exchange 2010 SP1";
    14732="Exchange 2010 SP2"
    }

$SchemaPathExchange = "CN=ms-Exch-Schema-Version-Pt,$SchemaPartition"
If (Test-Path "AD:$SchemaPathExchange") {
    $SchemaVersionExchange = (Get-ADObject $SchemaPathExchange -Property rangeUpper).rangeUpper
} Else {
    $SchemaVersionExchange = 0
}

$SchemaVersions += 1 | Select-Object `
    @{name="Product";expression={"Exchange"}}, `
    @{name="Schema";expression={$SchemaVersionExchange}}, `
    @{name="Version";expression={$SchemaHashExchange.Item($SchemaVersionExchange)}}

#------------------------------------------------------------------------------

$SchemaHashLync = @{
    1006="LCS 2005";
    1007="OCS 2007 R1";
    1008="OCS 2007 R2";
    1100="Lync Server 2010"
    }

$SchemaPathLync = "CN=ms-RTC-SIP-SchemaVersion,$SchemaPartition"
If (Test-Path "AD:$SchemaPathLync") {
    $SchemaVersionLync = (Get-ADObject $SchemaPathLync -Property rangeUpper).rangeUpper
} Else {
    $SchemaVersionLync = 0
}

$SchemaVersions += 1 | Select-Object `
    @{name="Product";expression={"Lync"}}, `
    @{name="Schema";expression={$SchemaVersionLync}}, `
    @{name="Version";expression={$SchemaHashLync.Item($SchemaVersionLync)}}

#------------------------------------------------------------------------------

"`nKnown current schema version of products:"
$SchemaVersions | Format-Table * -AutoSize

#---------------------------------------------------------------------------><>
