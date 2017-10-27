[CmdletBinding()]
param(
    [string]
    $DomainName,

    [string]
    $UserName,

    [string]
    $Password
)

try {
    $ErrorActionPreference = "Stop"

    $pass = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$pass

    Add-Computer -DomainName $DomainName -Credential $cred -ErrorAction Stop

    # Execute restart after script exit and allow time for external services
    Invoke-Expression -Command "shutdown.exe /r /t 10"
}
catch {
    $_ | Write-AWSQuickStartException
}
