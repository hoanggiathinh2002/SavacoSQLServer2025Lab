param (
    [Parameter(Mandatory = $false)]
    [string]$installType = "Full Lesson"
)

Write-Output "DEBUG: Received installType value: '$installType'"

$baseRepoUrl = "https://raw.githubusercontent.com/hoanggiathinh2002/SavacoSQLServer2025Lab/main/Artifacts/Lab02"
$labRoot = "C:\SQLServerAdminLabs\LabFiles\Lab02"
$solutionFolder = Join-Path $labRoot "Solution"
$starterFolder = Join-Path $labRoot "Starter"

# --- Create Directory Structure ---
$folders = @($labRoot, $solutionFolder, $starterFolder)
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
}

$solutionFiles = @{
    "No solution files.txt" = @{ Local = $solutionFolder; Remote = "Solution" }
}

switch ($installType) {
    "Setup Only" { 
        $filesToDownload = $setupFiles 
    }
    "Solution Only" { 
        $filesToDownload = $solutionFiles 
    }
    "Full Lab" { 
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

# --- Execute Environment Setup (Only if Setup files were downloaded) ---
if ($installType -eq "Setup Only" -or $installType -eq "Full Lab") {
    Set-Location $labRoot
    Write-Output "Running environment setup..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c Setup.cmd" -Wait
}

Write-Output "Lab 02 ($installType) Successfully Downloaded and Initialized."