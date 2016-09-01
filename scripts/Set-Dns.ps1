[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ns1,

    [Parameter(Mandatory=$true)]
    [string]$ns2
)

try {
    $ErrorActionPreference = "Stop"

    Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $ns1,$ns2

}
catch {
    $_ | Write-AWSQuickStartException
}