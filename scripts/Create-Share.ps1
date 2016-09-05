[CmdletBinding()]
param(

    [Parameter(Mandatory=$true)]
    [string]$DomainNetBIOSName,
    
    [Parameter(Mandatory=$true)]
    [string]$DomainAdminUser,
    
    [Parameter(Mandatory=$true)]
    [string]$DomainAdminPassword,

    [Parameter(Mandatory=$true)]
    [string]$ShareName,

    [Parameter(Mandatory=$true)]
    [string]$Path,

    [Parameter(Mandatory=$false)]
    [string]$ServerName='localhost'
ShareName
Path=c:\\sqlinstall
ADServer1NetBIOSName

)

try {
    Start-Transcript -Path C:\cfn\log\Create-Folder.ps1.txt -Append
    $ErrorActionPreference = "Stop"

    $DomainAdminFullUser = $DomainNetBIOSName + '\' + $DomainAdminUser
    $DomainAdminSecurePassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
    $DomainAdminCreds = New-Object System.Management.Automation.PSCredential($DomainAdminFullUser, $DomainAdminSecurePassword)
    $CreateFolderPs={
        New-SmbShare -Name $args[0] -Path $args[1] -FullAccess everyone
    }
    Invoke-Command -Scriptblock $CreateFolderPs -ComputerName $ServerName -Credential $DomainAdminCreds -ArgumentList $ShareName,$Path
}
catch {
    $_ | Write-AWSQuickStartException
}