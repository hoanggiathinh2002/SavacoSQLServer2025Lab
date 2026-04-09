param (
    [Parameter(Mandatory = $false)]
    [string]$installType = "Full Lesson"
)

Write-Output "DEBUG: Received installType value: '$installType'"

$baseRepoUrl = "https://raw.githubusercontent.com/hoanggiathinh2002/SavacoSQLServer2025Lab/main/Artifacts/Lab03"
$labRoot = "C:\SQLServerAdminLabs\LabFiles\Lab03"
$solutionFolder = Join-Path $labRoot "Solution"
$starterFolder = Join-Path $labRoot "Starter"
$setupFilesFolder = Join-Path $starterFolder "SetupFiles"

# --- Create Directory Structure ---
$folders = @($labRoot, $solutionFolder, $starterFolder, $setupFilesFolder)
foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force
    }
}

# --- Determine what to download ---
$filesToDownload = @{}

# Update your file groups to include the relative GitHub path
$setupFiles = @(
    [PSCustomObject]@{ Name = "Setup.cmd"; Local = $starterFolder; Remote = "Starter" }
    [PSCustomObject]@{ Name = "ViewFileInfo.sql"; Local = $starterFolder; Remote = "Starter" }
    [PSCustomObject]@{ Name = "AWDataWarehouse_current.ndf"; Local = $starterFolder; Remote = "Starter" }
    [PSCustomObject]@{ Name = "AWDataWarehouse_archive.ndf"; Local = $starterFolder; Remote = "Starter" }
    [PSCustomObject]@{ Name = "AWDataWarehouse.mdf"; Local = $starterFolder; Remote = "Starter" }
    [PSCustomObject]@{ Name = "AWDataWarehouse.ldf"; Local = $starterFolder; Remote = "Starter" }
    
    [PSCustomObject]@{ Name = "Setup.sql"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
    [PSCustomObject]@{ Name = "Setup2.sql"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
    [PSCustomObject]@{ Name = "Reset.sql"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
    
    # These duplicates are now allowed because they are distinct objects in a list
    [PSCustomObject]@{ Name = "AWDataWarehouse_current.ndf"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
    [PSCustomObject]@{ Name = "AWDataWarehouse_archive.ndf"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
    [PSCustomObject]@{ Name = "AWDataWarehouse.mdf"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
    [PSCustomObject]@{ Name = "AWDataWarehouse.ldf"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
)

$solutionFiles = @(
    [PSCustomObject]@{ Name = "Attach AWDataWarehouse.sql"; Local = $solutionFolder; Remote = "Solution" }
    [PSCustomObject]@{ Name = "Create HumanResource.sql"; Local = $solutionFolder; Remote = "Solution" }
    [PSCustomObject]@{ Name = "Create InternetSales.sql"; Local = $solutionFolder; Remote = "Solution" }
)

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
foreach ($file in $filesToDownload) {
    $fileName = $file.Name
    
    # Construct the URL: If Remote is provided, add it to path, otherwise just use base
    if (![string]::IsNullOrEmpty($file.Remote)) {
        $sourceUrl = "$baseRepoUrl/$($file.Remote)/$fileName"
    }
    else {
        $sourceUrl = "$baseRepoUrl/$fileName"
    }
    
    # Encode spaces in URL (important for "Attach AWDataWarehouse.sql")
    $sourceUrl = $sourceUrl -replace ' ', '%20'
    
    $destinationPath = Join-Path $file.Local $fileName
    
    Write-Output "Downloading: $fileName"
    try {
        Invoke-WebRequest -Uri $sourceUrl -OutFile $destinationPath -UseBasicParsing -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to download $fileName. Check if the URL is correct: $sourceUrl"
        exit 1
    }
}


# --- Execute Environment Setup ---
if ($installType -eq "Setup Only" -or $installType -eq "Full Lesson") {
    # Check if Setup.cmd exists before running
    $cmdPath = Join-Path $starterFolder "Setup.cmd"
    if (Test-Path $cmdPath) {
        Set-Location $starterFolder
        Write-Output "Running environment setup..."
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c Setup.cmd" -Wait
    }
}

Write-Output "Lesson 03 ($installType) Successfully Downloaded and Initialized."