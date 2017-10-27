[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$DomainName,

    [Parameter(Mandatory=$true)]
    [string]$UserName,

    [Parameter(Mandatory=$true)]
    [string]$Password,

    [Parameter(Mandatory=$false)]
    [string]$NewName,

    [Parameter(Mandatory=$false)]
    [switch]$Restart
)

try {
    $ErrorActionPreference = "Stop"

    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$securePassword

    $addComputerParams = @{
        DomainName = $DomainName
        Credential = $creds
        Force = $true
        ErrorAction = [System.Management.Automation.ActionPreference]::Stop
    }

    if (-not [string]::IsNullOrEmpty($NewName)) {
        $renameComputerParams = @{
            NewName = $NewName
            Force = $true
        }

        Rename-Computer @renameComputerParams

        $addComputerParams.Add("NewName",$NewName)
    }

    Add-Computer @addComputerParams

    if ($Restart) {
        # Execute restart after script exit and allow time for external services
        Invoke-Expression -Command "shutdown.exe /r /t 10"
    }
}
catch {
    $_ | Write-AWSQuickStartException
}
