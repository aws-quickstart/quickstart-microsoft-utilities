try {
    Start-Transcript -Path C:\cfn\log\DisableCredSSP.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    Disable-WSManCredSSP Client
    Disable-WSManCredSSP Server

    Remove-Item -Path 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly'
    Remove-ItemProperty -Path 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation' -Name 'AllowFreshCredentialsWhenNTLMOnly'
}
catch {
    $_ | Write-AWSQuickStartException
}
