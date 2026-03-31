<#
.SYNOPSIS
  Wrapper to install SQL Server silently using a configuration file.
.DESCRIPTION
  Downloads installer and config, checks for existing installation, runs silent install, logs output.
#>

param(
  [Parameter(Mandatory=$true)][string]$SqlInstallerUrl,
  [Parameter(Mandatory=$true)][string]$SqlConfigUrl,
  [Parameter(Mandatory=$false)][string]$SqlEdition = "Developer",
  [Parameter(Mandatory=$false)][string]$RebootIfRequired = "true"
)

$ErrorActionPreference = "Stop"
$logDir = "C:\Windows\Temp\dtl-artifact-logs"
New-Item -Path $logDir -ItemType Directory -Force | Out-Null
$logFile = Join-Path $logDir "install-sqlserver-$(Get-Date -Format yyyyMMdd-HHmmss).log"

function Log {
  param([string]$msg)
  $timestamp = (Get-Date).ToString("s")
  "$timestamp`t$msg" | Out-File -FilePath $logFile -Append -Encoding utf8
}

Log "Starting SQL Server artifact"
try {
  # Idempotency check: look for SQL Server instance or registry key
  $sqlInstalled = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' -ErrorAction SilentlyContinue
  if ($sqlInstalled) {
    Log "SQL Server appears already installed. Exiting successfully."
    exit 0
  }

  # Download installer and config
  $temp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "sqlinstall") -Force
  $installerPath = Join-Path $temp "sqlserver-installer.exe"
  $configPath = Join-Path $temp "ConfigurationFile.ini"

  Log "Downloading SQL installer from $SqlInstallerUrl"
  Invoke-WebRequest -Uri $SqlInstallerUrl -OutFile $installerPath -UseBasicParsing
  Log "Downloading SQL config from $SqlConfigUrl"
  Invoke-WebRequest -Uri $SqlConfigUrl -OutFile $configPath -UseBasicParsing

  # If your exported script used a different silent switch, adapt here.
  $arguments = "/Q /IAcceptSQLServerLicenseTerms /ConfigurationFile=`"$configPath`""
  Log "Running SQL Server installer: $installerPath $arguments"
  $proc = Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow
  Log "Installer exit code: $($proc.ExitCode)"

  if ($proc.ExitCode -ne 0) {
    Log "SQL Server installer failed with exit code $($proc.ExitCode)"
    exit $proc.ExitCode
  }

  Log "SQL Server installed successfully."

  # Optional: run post-install configuration from exported script (service accounts, firewall rules)
  # Insert any exported script steps here, e.g. restore master keys, enable features, apply patches.

  if ($RebootIfRequired -eq "true") {
    # Detect pending reboot
    $pending = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction SilentlyContinue)
    if ($pending) {
      Log "Reboot pending. Rebooting now."
      Restart-Computer -Force
    }
  }

  Log "SQL Server artifact completed successfully."
  exit 0
}
catch {
  Log "ERROR: $($_.Exception.Message)"
  exit 1
}
