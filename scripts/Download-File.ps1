[CmdletBinding()]
param(
    [string]
    $Source,

    [string]
    $Destination
)

try {
    ((new-object net.webclient).DownloadFile(
        $Source,$Destination       
    ))
}
catch {
    $_ | Write-AWSQuickStartException
}
