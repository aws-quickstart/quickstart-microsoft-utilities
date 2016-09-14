try {
    Start-Transcript -Path C:\cfn\log\DisableCredSSP.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    Disable-WSManCredSSP Client
    Disable-WSManCredSSP Server

}
catch {
    $_ | Write-AWSQuickStartException
}
