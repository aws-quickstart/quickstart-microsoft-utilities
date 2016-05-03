[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ImagePath
)

try {
    $ErrorActionPreference = "Stop"

    Mount-DiskImage -ImagePath $ImagePath
}
catch {
    $_ | Write-AWSQuickStartException
}