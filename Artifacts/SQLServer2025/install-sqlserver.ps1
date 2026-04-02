param(
    [string] $IsoPath,
    [string] $ProductKey,
    [bool]   $IgnorePendingReboot,
    [string] $SqlSetupParameters
)

Write-Host "Starting SQL Server 2025 installation..."

# --- Detect pending reboot ---
$pendingReboot = $false

if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") {
    $pendingReboot = $true
}
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") {
    $pendingReboot = $true
}
if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations") {
    $pendingReboot = $true
}

if ($pendingReboot -and -not $IgnorePendingReboot) {
    Write-Host "Pending reboot detected. Rebooting now..."
    shutdown /r /t 5
    exit 0
}

# --- Ensure Chocolatey exists ---
if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Write-Error "Chocolatey is not installed. Install Chocolatey artifact must run first."
    exit 1
}

# --- Build Chocolatey parameters ---
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

if ($chocoParams.Count -gt 0) {
    $paramString = "--params='" + ($chocoParams -join ' ') + "'"
} else {
    $paramString = ""
}

Write-Host "Installing SQL Server 2025 with parameters: $paramString"

# --- Install SQL Server ---
choco install sql-server-2025 -y --no-progress $paramString

if ($LASTEXITCODE -ne 0) {
    Write-Error "SQL Server 2025 installation failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host "SQL Server 2025 installation completed successfully."
exit 0
