<#
.SYNOPSIS
  Wrapper to install SSMS silently.
.DESCRIPTION
  Downloads SSMS installer, checks for existing SSMS, runs silent install, logs output.
#>

param(
  [Parameter(Mandatory=$true)][string]$SsmsInstallerUrl
)

$ErrorActionPreference = "Stop"
$logDir = "C:\Windows\Temp\dtl-artifact-logs"
New-Item -Path $logDir -ItemType Directory -Force | Out-Null
$logFile = Join-Path $logDir "install-ssms-$(Get-Date -Format yyyyMMdd-HHmmss).log"

function Log {
  param([string]$msg)
  $timestamp = (Get-Date).ToString("s")
  "$timestamp`t$msg" | Out-File -FilePath $logFile -Append -Encoding utf8
}

Log "Starting SSMS artifact"
try {
  # Idempotency check: look for SSMS registry key or executable
  $ssmsPath = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"
  if (Test-Path $ssmsPath) {
    Log "SSMS already installed at $ssmsPath. Exiting successfully."
    exit 0
  }

  $temp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "ssmsinstall") -Force
  $installerPath = Join-Path $temp "ssms-setup.exe"

  Log "Downloading SSMS installer from $SsmsInstallerUrl"
  Invoke-WebRequest -Uri $SsmsInstallerUrl -OutFile $installerPath -UseBasicParsing

  # SSMS silent install switches
  $arguments = "/install /quiet /norestart"
  Log "Running SSMS installer: $installerPath $arguments"
  $proc = Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow
  Log "Installer exit code: $($proc.ExitCode)"

  if ($proc.ExitCode -ne 0) {
    Log "SSMS installer failed with exit code $($proc.ExitCode)"
    exit $proc.ExitCode
  }

  Log "SSMS installed successfully."
  exit 0
}
catch {
  Log "ERROR: $($_.Exception.Message)"
  exit 1
}
