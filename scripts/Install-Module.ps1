[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string[]]$Name,

    [Parameter(Mandatory=$false)]
    [string[]]$Scope = 'AllUsers'
)

try {
    $ErrorActionPreference = "Stop"

    Import-Module PowerShellGet
    
    PowerShellGet\Install-Module -Name $Name -Scope $Scope
}
catch {
    $_ | Write-AWSQuickStartException
}
