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
    [string]$ServiceAccountUser,

    [Parameter(Mandatory=$true)]
    [string]$ServiceAccountPassword,

    [Parameter(Mandatory=$true)]
    [string]$ADServerNetBIOSName

)

try {
    Start-Transcript -Path C:\cfn\log\Create-ADServiceAccount.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    $DomainAdminFullUser = $DomainNetBIOSName + '\' + $DomainAdminUser
    $DomainAdminSecurePassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
    $DomainAdminCreds = New-Object System.Management.Automation.PSCredential($DomainAdminFullUser, $DomainAdminSecurePassword)
    $ServiceAccountSecurePassword = ConvertTo-SecureString $ServiceAccountPassword -AsPlainText -Force
    $UserPrincipalName = $ServiceAccountUser + "@" + $DomainDNSName
    $CreateUserPs={
        $ErrorActionPreference = "Stop"
        try {
            Get-ADUser -Identity $Using:ServiceAccountUser
        }
        catch {
            New-ADUser -Name $Using:ServiceAccountUser -UserPrincipalName $Using:UserPrincipalName -AccountPassword $Using:ServiceAccountSecurePassword -Enabled $true -PasswordNeverExpires $true -EA 0
        }

    }
    Invoke-Command -Scriptblock $CreateUserPs -ComputerName $ADServerNetBIOSName -Credential $DomainAdminCreds
}
catch {
    $_ | Write-AWSQuickStartException
}
