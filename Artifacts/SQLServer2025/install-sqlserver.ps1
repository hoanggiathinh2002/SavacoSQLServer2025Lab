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

function Install-Packages
{
    [CmdletBinding()]
    param(
        [string] $ChocoExePath,
        $Packages
    )

    $Packages = $Packages.split(',; ', [StringSplitOptions]::RemoveEmptyEntries)
    $Packages | % {
        $checkSumFlags = ""
        if ($AllowEmptyChecksums) { $checkSumFlags += " --allow-empty-checksums " }
        if ($IgnoreChecksums) { $checkSumFlags += " --ignore-checksums " }

        # --- THE KEY CHANGE IS HERE ---
        # We pass /SkipRules to the SQL installer via Chocolatey's --params
        $sqlParams = "--params ""'/SkipRules:RebootRequiredCheck'"""
        
        $expression = "$ChocoExePath install -y -f --acceptlicense $checkSumFlags --no-progress --stoponfirstfailure --ignore-reboots $sqlParams $_"
        
        Write-Host "Executing: $expression"
        Invoke-ExpressionImpl -Expression $expression
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
