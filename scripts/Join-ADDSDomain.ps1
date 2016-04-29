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

    if ($Restart) {
        $addComputerParams.Add("Restart",$true)
    }

    Add-Computer @addComputerParams
}
catch {
    $_ | Write-AWSQuickStartException
}