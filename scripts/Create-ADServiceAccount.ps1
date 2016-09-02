[CmdletBinding()]
param(

    [Parameter(Mandatory=$true)]
    [string]$DomainNetBIOSName,
    
    [Parameter(Mandatory=$true)]
    [string]$DomainAdminUser,
    
    [Parameter(Mandatory=$true)]
    [string]$DomainAdminPassword,

    [Parameter(Mandatory=$true)]
    [string]$DomainDNSName,

    [Parameter(Mandatory=$true)]
    [string]$ServiceAccount

)

try {
    Start-Transcript -Path C:\cfn\log\Create-ADServiceAccount.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    $DomainAdminPassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
    $DomainAdminCreds = New-Object System.Management.Automation.PSCredential('$DomainNetBIOSName\$DomainAdminUser', $DomainAdminPassword)
    $SQLServiceAccountPassword = ConvertTo-SecureString $SQLServiceAccountPassword -AsPlainText -Force
    $UserPrincipalName = $ServiceAccount + "@" + $DomainDNSName
    New-ADUser -Name $ServiceAccount -UserPrincipalName $UserPrincipalName -AccountPassword $SQLServiceAccountPassword -Enabled $true -PasswordNeverExpires $true -EA 0 -ComputerName $ADServer1NetBIOSName -Credential $DomainAdminCreds

}
catch {
    $_ | Write-AWSQuickStartException
}