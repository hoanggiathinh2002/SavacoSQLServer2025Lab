param (
    [Parameter(Mandatory = $false)]
    [string]$installType = "Full Lesson"
)

Write-Output "DEBUG: Received installType value: '$installType'"

$baseRepoUrl = "https://raw.githubusercontent.com/hoanggiathinh2002/SavacoSQLServer2025Lab/main/Artifacts/Lab04"
$labRoot = "C:\SQLServerAdminLabs\LabFiles\Lab04"
$solutionFolder = Join-Path $labRoot "Solution"
$starterFolder = Join-Path $labRoot "Starter"
$setupFilesFolder = Join-Path $starterFolder "SetupFiles"

# --- Create Directory Structure ---
$folders = @($labRoot, $solutionFolder, $starterFolder, $setupFilesFolder)
foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

# --- Define File Sets ---
# Note: Removed redundant database downloads to save time/bandwidth; we will copy them locally.
$setupFiles = @(
    [PSCustomObject]@{ Name = "Setup.cmd"; Local = $starterFolder; Remote = "Starter" }
    [PSCustomObject]@{ Name = "Update AWDataWarehouse.sql"; Local = $starterFolder; Remote = "Starter" }
    [PSCustomObject]@{ Name = "Update HumanResources.sql"; Local = $starterFolder; Remote = "Starter" }
    [PSCustomObject]@{ Name = "Update InternetSales.sql"; Local = $starterFolder; Remote = "Starter" }
    
    [PSCustomObject]@{ Name = "AWDataWarehouse.bak"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
    [PSCustomObject]@{ Name = "HumanResources.bak"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
    [PSCustomObject]@{ Name = "InternetSales.bak"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
    [PSCustomObject]@{ Name = "Setup.sql"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
    [PSCustomObject]@{ Name = "Setup2.sql"; Local = $setupFilesFolder; Remote = "Starter/Setupfiles" }
)

$solutionFiles = @(
    [PSCustomObject]@{ Name = "AWDataWarehouse.sql"; Local = $solutionFolder; Remote = "Solution" }
    [PSCustomObject]@{ Name = "HumanResources.sql"; Local = $solutionFolder; Remote = "Solution" }
    [PSCustomObject]@{ Name = "InternetSales.sql"; Local = $solutionFolder; Remote = "Solution" }
)

$filesToDownload = @()
switch ($installType) {
    "Setup Only" { $filesToDownload = $setupFiles }
    "Solution Only" { $filesToDownload = $solutionFiles }
    "Full Lab" { $filesToDownload = $setupFiles + $solutionFiles }
    Default { Write-Error "Invalid installType: '$installType'"; exit 1 }
}

# --- Download Execution ---
foreach ($file in $filesToDownload) {
    $fileName = $file.Name
    # Properly encode spaces for URLs (e.g., "Attach AWDataWarehouse.sql" -> "Attach%20AWDataWarehouse.sql")
    $encodedName = [uri]::EscapeDataString($fileName)
    $sourceUrl = "$baseRepoUrl/$($file.Remote)/$encodedName"
    $destinationPath = Join-Path $file.Local $fileName
    
    Write-Output "Downloading: $fileName"
    try {
        Invoke-WebRequest -Uri $sourceUrl -OutFile $destinationPath -UseBasicParsing -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to download $fileName. URL: $sourceUrl"
        exit 1
    }
}

# --- Handle Redundant Database Files via Local Copy (Faster & More Reliable) ---
if ($installType -match "Setup|Full") {
    $dbFiles = @("AWDataWarehouse.bak", "HumanResources.bak", "InternetSales.bak")
    foreach ($dbFile in $dbFiles) {
        $src = Join-Path $starterFolder $dbFile
        $dest = Join-Path $setupFilesFolder $dbFile
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination $dest -Force
        }
    }
}

# --- Execute Environment Setup ---
if ($installType -eq "Setup Only" -or $installType -eq "Full Lab") {
    $cmdPath = Join-Path $starterFolder "Setup.cmd"
    if (Test-Path $cmdPath) {
        Write-Output "Running environment setup: $cmdPath"
        
        # Change directory to ensure relative paths inside .cmd work correctly
        Push-Location $starterFolder
        
        # Run Setup.cmd and capture the process info
        $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c Setup.cmd" -Wait -NoNewWindow -PassThru
        
        Pop-Location

        if ($process.ExitCode -ne 0) {
            Write-Error "Setup.cmd failed with Exit Code $($process.ExitCode). Please check SQL Server logs or script logic."
            exit 1
        }
    }
    else {
        Write-Warning "Setup.cmd not found at $cmdPath"
    }
}

Write-Output "Lesson 04 ($installType) Successfully Downloaded and Initialized."