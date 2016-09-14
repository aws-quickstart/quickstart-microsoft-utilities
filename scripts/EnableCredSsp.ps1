try {
    Start-Transcript -Path C:\cfn\log\EnableCredSsp.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    Enable-WSManCredSSP Client -DelegateComputer * -Force
    Enable-WSManCredSSP Server -Force
    
}
catch {
    $_ | Write-AWSQuickStartException
}
