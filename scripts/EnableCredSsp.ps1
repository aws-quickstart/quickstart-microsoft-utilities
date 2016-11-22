[CmdletBinding()]
param(

    [Parameter(Mandatory=$false)]
    [string]$DomainDNSName,

    [Parameter(Mandatory=$false)]
    [string]$ServerName='*'
)

try {
    Start-Transcript -Path C:\cfn\log\EnableCredSsp.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    Enable-WSManCredSSP Client -DelegateComputer $ServerName -Force
    if ($DomainDNSName) {
        Enable-WSManCredSSP Client -DelegateComputer *.$DomainDNSName -Force
    }
    Enable-WSManCredSSP Server -Force

    $parentkey = "hklm:\SOFTWARE\Policies\Microsoft\Windows"
    $key = "$parentkey\CredentialsDelegation"
    $ntlmkey = "$key\AllowFreshCredentialsWhenNTLMOnly"
    New-Item -Path $parentkey -Name 'CredentialsDelegation' -Force
    New-Item -Path $key -Name 'AllowFreshCredentialsWhenNTLMOnly' -Force
    New-ItemProperty -Path $key -Name AllowFreshCredentialsWhenNTLMOnly -Value 1 -PropertyType Dword -Force
    New-ItemProperty -Path $ntlmkey -Name 1 -Value "WSMAN/$ServerName" -PropertyType String -Force
    if ($DomainDNSName) {
        New-ItemProperty -Path $ntlmkey -Name 2 -Value "WSMAN/*.$DomainDNSName" -PropertyType String -Force
    }

}
catch {
    $_ | Write-AWSQuickStartException
}
