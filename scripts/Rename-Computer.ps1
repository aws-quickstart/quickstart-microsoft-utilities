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

    if ($Restart) {
        $renameComputerParams.Add("Restart",$true)
    }

    Rename-Computer @renameComputerParams
}
catch {
    $_ | Write-AWSQuickStartException
}