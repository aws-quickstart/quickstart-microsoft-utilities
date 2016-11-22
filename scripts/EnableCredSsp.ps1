[CmdletBinding()]
param(

    [Parameter(Mandatory=$true)]
    [string]$DomainDNSName,

    [Parameter(Mandatory=$true)]
    [string]$ServerName
)

try {
    Start-Transcript -Path C:\cfn\log\EnableCredSsp.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    Enable-WSManCredSSP Client -DelegateComputer $ServerName -Force
    Enable-WSManCredSSP Client -DelegateComputer *.$DomainDNSName -Force
    Enable-WSManCredSSP Server -Force

    $key = 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'
    $ntlmkey = 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly'
    md $ntlmkey -Force
    New-ItemProperty -Path $key -Name AllowFreshCredentialsWhenNTLMOnly -Value 1 -PropertyType Dword -Force
    New-ItemProperty -Path $ntlmkey -Name 1 -Value "WSMAN/*.$DomainDNSName" -PropertyType String -Force
    New-ItemProperty -Path $ntlmkey -Name 2 -Value "WSMAN/$ServerName" -PropertyType String -Force

}
catch {
    $_ | Write-AWSQuickStartException
}
