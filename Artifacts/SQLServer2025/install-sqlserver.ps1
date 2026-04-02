param(
    [string] $IsoPath,
    [string] $ProductKey,
    [bool]   $IgnorePendingReboot,
    [string] $SqlSetupParameters
)

Write-Host "Starting SQL Server 2025 installation..."

# Ensure Chocolatey is installed
if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey not found. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey already installed."
}

$chocoParams = @()

if ($IsoPath -and $IsoPath.Trim() -ne "") {
    $chocoParams += "/IsoPath:$IsoPath"
}

if ($ProductKey -and $ProductKey.Trim() -ne "") {
    $chocoParams += "/PID:$ProductKey"
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
