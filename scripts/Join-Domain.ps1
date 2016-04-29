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
    $pass = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$pass
    
    Add-Computer -DomainName $DomainName -Credential $cred -Restart -ErrorAction Stop
}
catch {
    $_ | Write-AWSQuickStartException
}