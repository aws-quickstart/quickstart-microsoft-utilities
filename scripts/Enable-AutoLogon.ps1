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
    $winlogon = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'

    # Check for the AutoAdminLogon value and it's current status before applying.
    If(-Not($winlogon.GetValue("AutoAdminLogon") -eq "1")) {
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 1 -ErrorAction Stop | Out-Null
    } else { write "AutoAdminLogon already set to 1" }

    # Check for the DefaultUserName before applying
    If(-Not($winlogon.GetValue("DefaultUserName").split('@')[0] -eq $UserName)) {
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value $UserName -ErrorAction Stop | Out-Null
    } else { write "DefaultUserName is already set" }

    # Check for the DefaultPassword before applying
    If(-Not($winlogon.GetValue("DefaultPassword") -eq "$Password")) {
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value $Password -ErrorAction Stop | Out-Null
    } else { write "DefaultPassword already set" }

    # Add a startup script if specified
    if (-not [string]::IsNullOrEmpty($StartupScript)) {
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Name Install -Value $StartupScript -ErrorAction Stop | Out-Null
    }
}
catch {
    $_ | Write-AWSQuickStartException
}