param(
    [string] $IsoPath,
    [string] $PID,
    [bool]   $IgnorePendingReboot,
    [string] $SqlSetupParameters
)

Write-Host "Starting SQL Server 2025 installation..."

$chocoParams = @()

if ($IsoPath -and $IsoPath.Trim() -ne "") {
    $chocoParams += "/IsoPath:$IsoPath"
}

if ($PID -and $PID.Trim() -ne "") {
    $chocoParams += "/PID:$PID"
}

if ($IgnorePendingReboot) {
    $chocoParams += "/IgnorePendingReboot"
}

if ($SqlSetupParameters -and $SqlSetupParameters.Trim() -ne "") {
    $chocoParams += $SqlSetupParameters
}

# Build final parameter string (safe for DevTest Labs)
if ($chocoParams.Count -gt 0) {
    $paramString = "--params='" + ($chocoParams -join ' ') + "'"
} else {
    $paramString = ""
}

Write-Host "Installing SQL Server 2025 with parameters: $paramString"

choco install sql-server-2025 -y --no-progress $paramString

if ($LASTEXITCODE -ne 0) {
    Write-Error "SQL Server 2025 installation failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host "SQL Server 2025 installation completed successfully."
