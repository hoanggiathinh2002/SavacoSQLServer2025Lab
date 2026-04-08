param (
    [Parameter(Mandatory = $false)]
    [string]$InstallType = "Full Lesson"
)

# Clean the input: Remove extra quotes and leading/trailing spaces
$InstallType = $InstallType.Replace('"', '').Trim()

Write-Output "DEBUG: Received InstallType value: '$InstallType'"

$baseRepoUrl = "https://raw.githubusercontent.com/hoanggiathinh2002/SavacoSQLServer2025Lab/artifacts/sql-server-ssms/Artifacts/Lab01"
$labRoot = "C:\SQLServerAdminLabs\LabFiles\Lab01"
$solutionFolder = Join-Path $labRoot "Solution"
$projectFolder = Join-Path $solutionFolder "AWProject"
$starterFolder = Join-Path $labRoot "Starter"
$setupFilesFolder = Join-Path $starterFolder "SetupFiles"

# --- Create Directory Structure ---
$folders = @($labRoot, $solutionFolder, $starterFolder, $projectFolder, $setupFilesFolder)
foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force
    }
}

# --- Define File Groups ---
$setupFiles = @{
    "Setup.cmd" = $starterFolder
    "Setup.sql" = $setupFilesFolder
}

$solutionFiles = @{
    "GetDBinfo.sql"         = $solutionFolder
    "GetDatabases.ps1.txt"  = $solutionFolder
    "AWProject.ssmssln"     = $projectFolder
    "AWProject.ssmssqlproj" = $projectFolder
    "BackupDB.sql"          = $projectFolder
}

# --- Determine what to download ---
$filesToDownload = @{}

switch ($InstallType) {
    "Setup Only" { 
        $filesToDownload = $setupFiles 
    }
    "Solution Only" { 
        $filesToDownload = $solutionFiles 
    }
    "Full Lesson" { 
        $filesToDownload = $setupFiles + $solutionFiles 
    }
    Default { 
        Write-Error "Invalid InstallType specified: '$InstallType'"; exit 1
    }
}

# --- Download Execution ---
foreach ($fileName in $filesToDownload.Keys) {
    $sourceUrl = "$baseRepoUrl/$fileName"
    $destinationPath = Join-Path $filesToDownload[$fileName] $fileName
    
    Write-Output "Downloading $fileName..."
    Invoke-WebRequest -Uri $sourceUrl -OutFile $destinationPath -UseBasicParsing
}

# --- Post-Download Tweaks ---
# Rename the PowerShell text file to a functional script 
$psTxtFile = Join-Path $solutionFolder "GetDatabases.ps1.txt"
$psFile = Join-Path $solutionFolder "GetDatabases.ps1"
if (Test-Path $psTxtFile) { Rename-Item -Path $psTxtFile -NewName "GetDatabases.ps1" -Force }

# --- Execute Environment Setup (Only if Setup files were downloaded) ---
if ($InstallType -eq "Setup Only" -or $InstallType -eq "Full Lesson") {
    Set-Location $labRoot
    Write-Output "Running environment setup..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c Setup.cmd" -Wait
}

Write-Output "Lesson 01 ($InstallType) Successfully Downloaded and Initialized."