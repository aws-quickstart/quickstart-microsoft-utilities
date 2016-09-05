[CmdletBinding()]
param(

    [Parameter(Mandatory=$true)]
    [string]$DomainNetBIOSName,
    
    [Parameter(Mandatory=$true)]
    [string]$DomainAdminUser,
    
    [Parameter(Mandatory=$true)]
    [string]$DomainAdminPassword,

    [Parameter(Mandatory=$true)]
    [string]$FolderPath,

    [Parameter(Mandatory=$true)]
    [string]$FolderName,

    [Parameter(Mandatory=$false)]
    [string]$ServerName='localhost'

)

try {
    Start-Transcript -Path C:\cfn\log\Create-Folder.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    $DomainAdminFullUser = $DomainNetBIOSName + '\' + $DomainAdminUser
    $DomainAdminSecurePassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
    $DomainAdminCreds = New-Object System.Management.Automation.PSCredential($DomainAdminFullUser, $DomainAdminSecurePassword)
    $CreateFolderPs={
        New-Item -ItemType directory -Path $args[0] -Name $args[1]
    }
    Invoke-Command -Scriptblock $CreateFolderPs -ComputerName $ServerName -Credential $DomainAdminCreds -ArgumentList $FolderPath,$FolderName
}
catch {
    $_ | Write-AWSQuickStartException
}