[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Source,

    [Parameter(Mandatory=$true)]
    [string]$Destination
)

try {
    $ErrorActionPreference = "Stop"

    $parentDir = Split-Path $Destination -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType directory -Force | Out-Null
    }

    (New-Object System.Net.WebClient).DownloadFile($Source,$Destination)
}
catch {
    $_ | Write-AWSQuickStartException
}
