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
    [string]$ServiceAccountUser

    [Parameter(Mandatory=$true)]
    [string]$ServiceAccountPassword

)

try {
    Start-Transcript -Path C:\cfn\log\Create-ADServiceAccount.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    $DomainAdminPassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
    $DomainAdminCreds = New-Object System.Management.Automation.PSCredential('$DomainNetBIOSName\$DomainAdminUser', $DomainAdminPassword)
    $ServiceAccountPassword = ConvertTo-SecureString $ServiceAccountPassword -AsPlainText -Force
    $UserPrincipalName = $ServiceAccountUser + "@" + $DomainDNSName
    New-ADUser -Name $ServiceAccountUser -UserPrincipalName $UserPrincipalName -AccountPassword $ServiceAccountPassword -Enabled $true -PasswordNeverExpires $true -EA 0 -ComputerName $ADServer1NetBIOSName -Credential $DomainAdminCreds

}
catch {
    $_ | Write-AWSQuickStartException
}