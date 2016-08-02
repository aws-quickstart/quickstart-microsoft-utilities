[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Source,

    [Parameter(Mandatory=$true)]
    [string]$Destination
)

function Get-S3BucketName {
    param(
        [Parameter(Mandatory=$true)]
        [string]$S3Uri
    )

    return ($S3Uri -split '/')[2]
}

function Get-S3Key {
    param(
        [Parameter(Mandatory=$true)]
        [string]$S3Uri
    )

    $bucketName = Get-S3BucketName -S3Uri $S3Uri

    return $S3Uri.Substring(("s3://$bucketName/").Length)
}

try {
    $ErrorActionPreference = "Stop"

    $parentDir = Split-Path $Destination -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType directory -Force | Out-Null
    }

    $qualifier = Split-Path $Source -Qualifier
    if ($qualifier -eq "s3:") {
        $tries = 5
        while ($tries -ge 1) {
            try {
                Read-S3Object -BucketName (Get-S3BucketName -S3Uri $Source) -Key (Get-S3Key -S3Uri $Source) -File $Destination -ErrorAction Stop
                break
            }
            catch {
                $tries--
                Write-Verbose "Exception:"
                Write-Verbose "$_"
                if ($tries -lt 1) {
                    throw $_
                }
                else {
                    Write-Verbose "Failed download. Retrying again in 5 seconds"
                    Start-Sleep 5
                }
            }
        }
    } elseif ($qualifier -in ("http:","https:")) {
        Write-Verbose "Trying to download from $Source"
        $tries = 5
        while ($tries -ge 1) {
            try {
                (New-Object System.Net.WebClient).DownloadFile($Source,$Destination)
                break
            }
            catch {
                $tries--
                Write-Verbose "Exception:"
                Write-Verbose "$_"
                if ($tries -lt 1) {
                    throw $_
                }
                else {
                    Write-Verbose "Failed download. Retrying again in 5 seconds"
                    Start-Sleep 5
                }
            }
        }
    } else {
        throw "$Source is not a valid S3, HTTP, or HTTPS URI"
    }
}
catch {
    $_ | Write-AWSQuickStartException
}
