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

    [Parameter(Mandatory=$false)]
    [string]$ADServerNetBIOSName='localhost'

)

try {
    Start-Transcript -Path C:\cfn\log\Create-ADServiceAccount.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    $DomainAdminFullUser = $DomainNetBIOSName + '\' + $DomainAdminUser
    $ServiceAccountFullUser = $DomainNetBIOSName + '\' + $ServiceAccountUser
    $DomainAdminSecurePassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
    $DomainAdminCreds = New-Object System.Management.Automation.PSCredential($DomainAdminFullUser, $DomainAdminSecurePassword)
    $ServiceAccountSecurePassword = ConvertTo-SecureString $ServiceAccountPassword -AsPlainText -Force
    $UserPrincipalName = $ServiceAccountUser + "@" + $DomainDNSName
    $CreateUserPs={
        $ErrorActionPreference = "Stop"
        if (!(Get-Module -ListAvailable -Name ActiveDirectory)) {
            Add-WindowsFeature RSAT-AD-PowerShell
        }
        try {
            Get-ADUser -Identity $Using:ServiceAccountUser
        }
        catch {
            New-ADUser -Name $Using:ServiceAccountUser -UserPrincipalName $Using:UserPrincipalName -AccountPassword $Using:ServiceAccountSecurePassword -Enabled $true -PasswordNeverExpires $true
        }
        if ((new-object directoryservices.directoryentry "", $Using:ServiceAccountFullUser, $Using:ServiceAccountPassword).psbase.name -eq $null){
            throw "Password for $Using:ServiceAccountUser is not valid"
        }

    }
    try {
        Invoke-Command -Scriptblock $CreateUserPs -ComputerName $ADServerNetBIOSName -Credential $DomainAdminCreds
    }
    catch {
        Invoke-Command -Scriptblock $CreateUserPs -ComputerName $ADServerNetBIOSName -Credential $DomainAdminCreds -Authentication Credssp
    }
}
catch {
    $_ | Write-AWSQuickStartException
}
