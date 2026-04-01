param(
    [Parameter(Mandatory=$true)]
    [string]$installerUrl,

    [Parameter(Mandatory=$true)]
    [string]$saPassword
)

$ErrorActionPreference = "Stop"
$downloadPath = "$env:TEMP\sql2025-install"
New-Item -ItemType Directory -Force -Path $downloadPath | Out-Null

# Determine if the URL points to an ISO file (ignoring URL parameters like SAS tokens)
$isIso = $installerUrl -match "\.iso(\?.*)?$"
$localFile = if ($isIso) { "$downloadPath\sql2025.iso" } else { "$downloadPath\setup.exe" }

Write-Host "Downloading SQL Server 2025 media from the provided URL..."
# UseBasicParsing ensures compatibility with older PowerShell environments
Invoke-WebRequest -Uri $installerUrl -OutFile $localFile -UseBasicParsing

$setupExePath = $localFile

if ($isIso) {
    Write-Host "ISO file detected. Mounting image..."
    $mountResult = Mount-DiskImage -ImagePath $localFile -PassThru
    $driveLetter = ($mountResult | Get-Volume).DriveLetter
    $setupExePath = "${driveLetter}:\setup.exe"
}

Write-Host "Starting silent installation of SQL Server 2025 Engine..."

# Standard silent install arguments for the SQL Server Engine
# This installs the default instance (MSSQLSERVER) with Mixed Mode authentication
$installArgs = @(
    "/q",
    "/ACTION=Install",
    "/FEATURES=SQLEngine",
    "/INSTANCENAME=MSSQLSERVER",
    "/SQLSVCACCOUNT=`"NT AUTHORITY\System`"",
    "/SQLSYSADMINACCOUNTS=`"BUILTIN\Administrators`"",
    "/SECURITYMODE=SQL",
    "/SAPWD=`"$saPassword`"",
    "/IACCEPTSQLSERVERLICENSETERMS",
    "/UpdateEnabled=0"
)

# Run the installer and wait for it to finish
$process = Start-Process -FilePath $setupExePath -ArgumentList $installArgs -Wait -PassThru

if ($isIso) {
    Write-Host "Installation complete. Dismounting ISO..."
    Dismount-DiskImage -ImagePath $localFile
}

# Exit code 0 means success. 3010 means success, but requires reboot.
if ($process.ExitCode -eq 0) {
    Write-Host "SQL Server 2025 installed successfully."
} elseif ($process.ExitCode -eq 3010) {
    Write-Host "SQL Server 2025 installed successfully. A reboot is required."
} else {
    Write-Error "SQL Server installation failed with exit code $($process.ExitCode)."
    exit $process.ExitCode
}

Write-Host "Cleaning up downloaded media..."
Remove-Item -Path $downloadPath -Recurse -Force

Write-Host "SQL Server 2025 Artifact execution completed successfully."
