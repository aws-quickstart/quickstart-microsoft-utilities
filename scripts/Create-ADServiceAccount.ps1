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
    [string]$ADServerNetBIOSName=$env:COMPUTERNAME

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
    $createUserSB = {
        $ErrorActionPreference = "Stop"
        if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
            Install-WindowsFeature RSAT-AD-PowerShell
        }
        Write-Host "Searching for user $Using:ServiceAccountUser"
        if (Get-ADUser -Filter {sAMAccountName -eq $Using:ServiceAccountUser}) {
            Write-Host "User already exists."
            # Ensure that password is correct for the user
            if ((New-Object System.DirectoryServices.DirectoryEntry "", $Using:ServiceAccountFullUser, $Using:ServiceAccountPassword).PSBase.Name -eq $null) {
                throw "The password for $Using:ServiceAccountUser is incorrect"
            }
        } else {
            Write-Host "Creating user $Using:ServiceAccountUser"
            New-ADUser -Name $Using:ServiceAccountUser -UserPrincipalName $Using:UserPrincipalName -AccountPassword $Using:ServiceAccountSecurePassword -Enabled $true -PasswordNeverExpires $true
        }
    }

    try {
        Write-Host "Invoking command on $ADServerNetBIOSName"
        Invoke-Command -ScriptBlock $createUserSB -ComputerName $ADServerNetBIOSName -Credential $DomainAdminCreds
    }
    catch {
        Write-Host $_
        Write-Host "Retrying user creation with CredSSP."
        Invoke-Command -ScriptBlock $createUserSB -ComputerName $ADServerNetBIOSName -Credential $DomainAdminCreds -Authentication Credssp
    }
}
catch {
    $_ | Write-AWSQuickStartException
}
