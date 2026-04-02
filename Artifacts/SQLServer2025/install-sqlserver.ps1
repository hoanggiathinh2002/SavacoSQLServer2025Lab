<#
.SYNOPSIS
    Installs SQL Server 2025 via Chocolatey for Azure DevTest Labs.
#>

[CmdletBinding()]
param(
    [string] $Packages = "sql-server-2025",
    [bool] $AllowEmptyChecksums = $true,
    [bool] $IgnoreChecksums = $false,
    [int] $PSVersionRequired = 3
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Force TLS 1.2 for Chocolatey Gallery downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$choco = "$Env:ProgramData\chocolatey\bin\choco.exe"

################################################################################
# Functions
################################################################################

function Ensure-Chocolatey {
    [CmdletBinding()]
    param([string] $ChocoExePath)

    # Pin to v1.4.0 to avoid breaking changes in v2.x during automation
    $env:chocolateyVersion = '1.4.0'

    if (-not (Test-Path "$ChocoExePath")) {
        Write-Host "Chocolatey not found. Installing..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
}

function Install-Packages {
    [CmdletBinding()]
    param(
        [string] $ChocoExePath,
        [string] $PackagesList
    )

    $pkgs = $PackagesList.split(',; ', [StringSplitOptions]::RemoveEmptyEntries)
    
    foreach ($pkg in $pkgs) {
        Write-Host "Starting installation of: $pkg"
        
        $checkSumFlags = ""
        if ($AllowEmptyChecksums) { $checkSumFlags += " --allow-empty-checksums" }
        if ($IgnoreChecksums) { $checkSumFlags += " --ignore-checksums" }

        # --ignore-reboots is CRITICAL. 
        # It prevents Choco from returning 3010, which Azure often treats as a failure.
        $expression = "& '$ChocoExePath' install $pkg -y -f --acceptlicense --no-progress --ignore-reboots $checkSumFlags --install-arguments='""/SkipRules=RebootRequiredCheck""'"
        
        Write-Debug "Executing: $expression"
        Invoke-Expression -Command $expression

        if ($LastExitCode -ne 0 -and $LastExitCode -ne 3010) {
            throw "Package '$pkg' failed to install with Exit Code: $LastExitCode"
        }
    }
}

################################################################################
# Execution
################################################################################

try {
    Write-Host "--- Starting SQL Server Artifact Execution ---"
    
    if ($PSVersionTable.PSVersion.Major -lt $PSVersionRequired) {
        throw "PowerShell $PSVersionRequired or higher is required."
    }

    Write-Host "Step 1: Ensuring Chocolatey is present..."
    Ensure-Chocolatey -ChocoExePath "$choco"

    Write-Host "Step 2: Installing SQL Server 2025..."
    # Note: We rely on the PREVIOUS artifact to have handled any pending reboots.
    Install-Packages -ChocoExePath "$choco" -PackagesList $Packages

    Write-Host "--- Artifact Applied Successfully ---"
    exit 0
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "The artifact failed to apply."
    exit -1
}
