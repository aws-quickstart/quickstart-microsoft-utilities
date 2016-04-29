[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $UserName,

    [Parameter(Mandatory=$true)]
    [string]
    $Password,

    [Parameter(Mandatory=$false)]
    [string]
    $StartupScript
)

try {
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 1 -ErrorAction Stop | Out-Null
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value $UserName -ErrorAction Stop | Out-Null
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value $Password -ErrorAction Stop | Out-Null
    if (-not [string]::IsNullOrEmpty($StartupScript)) {
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Name Install -Value $StartupScript -ErrorAction Stop | Out-Null
    }
}
catch {
    $_ | Write-AWSQuickStartException
}