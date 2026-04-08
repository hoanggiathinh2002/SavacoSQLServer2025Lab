param (
    [Parameter(Mandatory = $false)]
    [string]$installType = "Full Lesson"
)

Write-Output "DEBUG: Received installType value: '$installType'"

$baseRepoUrl = "https://raw.githubusercontent.com/hoanggiathinh2002/SavacoSQLServer2025Lab/main/Artifacts/Lab01"
$labRoot = "C:\SQLServerAdminLabs\LabFiles\Lab01"
$solutionFolder = Join-Path $labRoot "Solution"
$projectFolder = Join-Path $solutionFolder "AWProject"
$starterFolder = Join-Path $labRoot "Starter"
$setupFilesFolder = Join-Path $starterFolder "Setupfiles"

# --- Create Directory Structure ---
$folders = @($labRoot, $solutionFolder, $starterFolder, $projectFolder, $setupFilesFolder)
foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force
    }
}

# --- Determine what to download ---
$filesToDownload = @{}

# Update your file groups to include the relative GitHub path
$setupFiles = @{
    "Setup.cmd" = @{ Local = $starterFolder; Remote = "Starter" }
    "Setup.sql" = @{ Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
}

$solutionFiles = @{
    "GetDBinfo.sql"         = @{ Local = $solutionFolder; Remote = "Solution" }
    "GetDatabases.ps1.txt"  = @{ Local = $solutionFolder; Remote = "Solution" }
    "AWProject.ssmssln"     = @{ Local = $projectFolder; Remote = "Solution/AWProject" }
    "AWProject.ssmssqlproj" = @{ Local = $projectFolder; Remote = "Solution/AWProject" }
    "BackupDB.sql"          = @{ Local = $projectFolder; Remote = "Solution/AWProject" }
}

switch ($installType) {
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
        Write-Error "Invalid installType specified: '$installType'"; exit 1
    }
}

# --- Download Execution ---
foreach ($fileName in $filesToDownload.Keys) {
    $fileInfo = $filesToDownload[$fileName]
    
    # Construct the URL carefully
    if ($fileInfo.Remote -ne "") {
        $sourceUrl = "$baseRepoUrl/$($fileInfo.Remote)/$fileName"
    }
    else {
        $sourceUrl = "$baseRepoUrl/$fileName"
    }
    
    $destinationPath = Join-Path $fileInfo.Local $fileName
    
    Write-Output "Downloading from: $sourceUrl" # Debugging line
    try {
        Invoke-WebRequest -Uri $sourceUrl -OutFile $destinationPath -UseBasicParsing -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to download $fileName. Check if the URL is correct: $sourceUrl"
        exit 1
    }
}

# --- Post-Download Tweaks ---
# Rename the PowerShell text file to a functional script 
$psTxtFile = Join-Path $solutionFolder "GetDatabases.ps1.txt"
$psFile = Join-Path $solutionFolder "GetDatabases.ps1"
if (Test-Path $psTxtFile) { Rename-Item -Path $psTxtFile -NewName "GetDatabases.ps1" -Force }

# --- Execute Environment Setup (Only if Setup files were downloaded) ---
if ($installType -eq "Setup Only" -or $installType -eq "Full Lesson") {
    Set-Location $labRoot
    Write-Output "Running environment setup..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c Setup.cmd" -Wait
}

Write-Output "Lesson 01 ($installType) Successfully Downloaded and Initialized."