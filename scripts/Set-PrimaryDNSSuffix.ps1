[CmdletBinding()]
param (
    [string]
    [Parameter(Mandatory=$true, Position=0)]
    $Suffix
)

# http://msdn.microsoft.com/en-us/library/ms724224(v=vs.85).aspx
$ComputerNamePhysicalDnsDomain = 6

try {
    Write-Verbose "Setting DNS Suffix"
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

namespace ComputerSystem {
    public class Identification {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        static extern bool SetComputerNameEx(int NameType, string lpBuffer);
        
        public static bool SetPrimaryDnsSuffix(string suffix) {
            try {
                return SetComputerNameEx($ComputerNamePhysicalDnsDomain, suffix);
            }
            catch (Exception) {
                return false;
            }
        }
    }
}
"@

    [ComputerSystem.Identification]::SetPrimaryDnsSuffix($Suffix)

    Write-Verbose "Rebooting computer..."

    $ErrorActionPreference = "Stop"

    $shutdown = Start-Process -FilePath "shutdown.exe" -ArgumentList @("/r", "/t 10") -Wait -NoNewWindow -PassThru
    if ($shutdown.ExitCode -ne 0) {
        throw "[ERROR] shutdown.exe exit code was not 0. It was actually $($shutdown.ExitCode)."
    }
}
catch {
    $_ | Write-AWSQuickStartException
}