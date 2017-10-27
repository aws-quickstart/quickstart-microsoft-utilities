[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$NewName,

    [Parameter(Mandatory=$false)]
    [switch]$Restart
)

try {
    $ErrorActionPreference = "Stop"

    $renameComputerParams = @{
        NewName = $NewName
    }

    Rename-Computer @renameComputerParams

    if ($Restart) {
        # Execute restart after script exit and allow time for external services
        Invoke-Expression -Command "shutdown.exe /r /t 10"
    }
}
catch {
    $_ | Write-AWSQuickStartException
}
