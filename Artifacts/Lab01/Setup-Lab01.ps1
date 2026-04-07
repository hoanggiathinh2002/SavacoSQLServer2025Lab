# --- Configuration ---
$baseRepoUrl = "https://raw.githubusercontent.com/YourUser/YourRepo/main/Lesson01" # Change this!
$labRoot = "C:\SQLServerAdminLabs\LabFiles\Lab01\Starter"
$solutionFolder = Join-Path $labRoot "Solution"
$projectFolder = Join-Path $solutionFolder "AWProject"
$setupFilesFolder = Join-Path $labRoot "SetupFiles"

# --- Create Directory Structure ---
$folders = @($labRoot, $solutionFolder, $projectFolder, $setupFilesFolder)
foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force
    }
}

# --- File Mapping (Source File Name -> Local Destination Path) ---
$filesToDownload = @{
    "Setup.cmd"            = $labRoot
    "Setup.sql"            = $setupFilesFolder
    "AWProject.ssmssln"    = $solutionFolder
    "GetDBinfo.sql"        = $solutionFolder
    "GetDatabases.ps1.txt" = $solutionFolder
    "AWProject.ssmssqlproj"= $projectFolder
    "BackupDB.sql"         = $projectFolder
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

# --- Execute Environment Setup ---
Set-Location $labRoot
# This triggers the service restart and DB cleanup 
Start-Process -FilePath "cmd.exe" -ArgumentList "/c Setup.cmd" -Wait

Write-Output "Lesson 01 Environment Successfully Downloaded and Initialized."
