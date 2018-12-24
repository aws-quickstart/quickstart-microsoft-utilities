[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Source = 'https://go.microsoft.com/fwlink/?linkid=839516',

    [Parameter(Mandatory=$false)]
    [string]$Destination = 'C:\cfn\downloads\Win8.1AndW2K12R2-KB3191564-x64.msu'
)

try {
    $ErrorActionPreference = "Stop"

    $parentDir = Split-Path $Destination -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType directory -Force | Out-Null
    }

    Write-Verbose "Trying to download from $Source"
    $tries = 5
    while ($tries -ge 1) {
        try {
            (New-Object System.Net.WebClient).DownloadFile($Source,$Destination)
            break
        }
        catch {
            $tries--
            Write-Verbose "Exception:"
            Write-Verbose "$_"
            if ($tries -lt 1) {
                throw $_
            }
            else {
                Write-Verbose "Failed download. Retrying again in 5 seconds"
                Start-Sleep 5
            }
        }
    }
    
    if ([System.IO.Path]::GetExtension($Destination) -eq '.msu') {
        Start-Process -FilePath wusa.exe -ArgumentList $Destination,'/quiet','/norestart' -Wait
    } else {
        throw "Unsupported file extension"
    }
}
catch {
    $_ | Write-AWSQuickStartException
}
