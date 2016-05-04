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
        Read-S3Object -BucketName (Get-S3BucketName -S3Uri $Source) -Key (Get-S3Key -S3Uri $Source) -File $Destination
    } elseif ($qualifier -in ("http:","https:")) {
        (New-Object System.Net.WebClient).DownloadFile($Source,$Destination)
    } else {
        throw "$Source is not a valid S3, HTTP, or HTTPS URI"
    }
}
catch {
    $_ | Write-AWSQuickStartException
}
