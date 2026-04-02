##################################################################################################
#
# Parameters to this script file.
#

[CmdletBinding()]
param(
    # Space-, comma- or semicolon-separated list of Chocolatey packages.
    [string] $Packages,

    # Boolean indicating if we should allow empty checksums. Default to true to match previous artifact functionality despite security
    [bool] $AllowEmptyChecksums = $true,

    # Boolean indicating if we should ignore checksums. Default to false for security
    [bool] $IgnoreChecksums = $false,
    
    # Minimum PowerShell version required to execute this script.
    [int] $PSVersionRequired = 3
)

###################################################################################################
#
# PowerShell configurations
#

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$choco = "$Env:ProgramData/chocolatey/choco.exe"

###################################################################################################
#
# Handle all errors in this script.
#

trap
{
    $message = $Error[0].Exception.Message
    if ($message)
    {
        Write-Host -Object "`nERROR: $message" -ForegroundColor Red
    }

    Write-Host "`nThe artifact failed to apply.`n"
    exit -1
}

###################################################################################################
#
# Functions used in this script.
#

function Ensure-Chocolatey
{
    [CmdletBinding()]
    param(
        [string] $ChocoExePath
    )

    $env:chocolateyVersion = '1.4.0'

    if (-not (Test-Path "$ChocoExePath"))
    {
        Set-ExecutionPolicy Bypass -Scope Process -Force; 
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

        if ($LastExitCode -eq 3010)
        {
            Write-Host 'The recent changes indicate a reboot is necessary. Please reboot at your earliest convenience.'
        }
    }
}

function Ensure-PowerShell
{
    [CmdletBinding()]
    param(
        [int] $Version
    )

    if ($PSVersionTable.PSVersion.Major -lt $Version)
    {
        throw "The current version of PowerShell is $($PSVersionTable.PSVersion.Major). Prior to running this artifact, ensure you have PowerShell $Version or higher installed."
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
        if ($AllowEmptyChecksums)
        {
            $checkSumFlags += " --allow-empty-checksums "
        }
        if ($IgnoreChecksums)
        {
            $checkSumFlags += " --ignore-checksums "
        }
        $expression = "$ChocoExePath install -y -f --acceptlicense $checkSumFlags --no-progress --stoponfirstfailure $_"
        Invoke-ExpressionImpl -Expression $expression
    }
}

function Invoke-ExpressionImpl
{
    [CmdletBinding()]
    param(
        $Expression
    )

    iex $Expression -ErrorVariable expError

    if ($LastExitCode -or $expError)
    {
        if ($LastExitCode -eq 3010)
        {
            # Expected reboot condition
        }
        elseif ($expError[0])
        {
            throw $expError[0]
        }
        else
        {
            throw "Installation failed ($LastExitCode). Please see the Chocolatey logs in %ALLUSERSPROFILE%\chocolatey\logs folder for details."
        }
    }
}

function Validate-Params
{
    [CmdletBinding()]
    param()

    if ([string]::IsNullOrEmpty($Packages))
    {
        throw 'Packages parameter is required.'
    }
}

###################################################################################################
#
# Main execution block.
#

try
{
    pushd $PSScriptRoot

    Write-Host 'Validating parameters.'
    Validate-Params

    Write-Host 'Configuring PowerShell session.'
    Ensure-PowerShell -Version $PSVersionRequired
    Enable-PSRemoting -Force -SkipNetworkProfileCheck | Out-Null

    Write-Host 'Ensuring Chocolatey is installed.'
    Ensure-Chocolatey -ChocoExePath "$choco"

    Write-Host "Preparing to install Chocolatey packages: $Packages."
    Install-Packages -ChocoExePath "$choco" -Packages $Packages

    ###################################################################################################
    #
    # Install SQL Server 2025 Developer Edition from ISO
    #

    Write-Host "Starting SQL Server 2025 installation."

    $isoPath = "c:\downloads\SQLServer2025-x64-ENU-Dev.iso"

    if (-not (Test-Path $isoPath)) {
        throw "SQL Server ISO not found at $isoPath"
    }

    $expression = "sql-server-2025 --params ""'/IsoPath:$isoPath'"""
    Write-Host "Executing: $expression"
    Invoke-ExpressionImpl -Expression $expression

    Write-Host "SQL Server 2025 installation completed."

    ###################################################################################################

    Write-Host "`nThe artifact was applied successfully.`n"
}
finally
{
    popd
}
