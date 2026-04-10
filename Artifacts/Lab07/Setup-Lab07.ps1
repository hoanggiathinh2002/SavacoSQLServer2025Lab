param (
    [Parameter(Mandatory = $false)]
    [string]$installType = "Full Lesson"
)

# --- Configuration ---
$owner = "hoanggiathinh2002"
$repo = "SavacoSQLServer2025Lab"
$basePath = "Artifacts/Lab07" 
$localRoot = "C:\SQLServerAdminLabs\LabFiles\Lab07"
$tempStage = "C:\SQLServerAdminLabs\TempStage_Lab07"

# --- Function: Recursive GitHub Download ---
function Get-GitHubFolder {
    param (
        [string]$RepoPath,
        [string]$LocalPath
    )
    if (!(Test-Path $LocalPath)) {
        New-Item -ItemType Directory -Path $LocalPath -Force | Out-Null
    }

    $apiUrl = "https://api.github.com/repos/$owner/$repo/contents/$RepoPath"
    
    try {
        $items = Invoke-RestMethod -Uri $apiUrl -Method Get -UseBasicParsing
        foreach ($item in $items) {
            $targetLocalPath = Join-Path $LocalPath $item.name
            if ($item.type -eq "dir") {
                Get-GitHubFolder -RepoPath $item.path -LocalPath $targetLocalPath
            } 
            elseif ($item.type -eq "file") {
                Write-Host "Fetching: $($item.name)" -ForegroundColor Cyan
                Invoke-WebRequest -Uri $item.download_url -OutFile $targetLocalPath -UseBasicParsing
            }
        }
    }
    catch {
        Write-Error "Failed to sync with GitHub API. Check your connection or API limits."
    }
}

# --- 1. Preparation ---
Write-Host "Step 1: Cleaning temporary staging area..." -ForegroundColor Yellow
if (Test-Path $tempStage) { Remove-Item $tempStage -Recurse -Force }
New-Item -ItemType Directory -Path $tempStage -Force | Out-Null

# --- 2. Download from GitHub to Temp ---
Write-Host "Step 2: Downloading all files from GitHub to Staging..." -ForegroundColor Yellow
Get-GitHubFolder -RepoPath $basePath -LocalPath $tempStage

# --- 3. Execute Setup.cmd (The 'Cleaner') ---
# We run this BEFORE moving the new files so it only deletes OLD data.
$cmdPath = Join-Path $localRoot "Starter\Setup.cmd"
if (Test-Path $cmdPath) {
    Write-Host "Step 3: Running Setup.cmd to clean environment..." -ForegroundColor Yellow
    Push-Location (Split-Path $cmdPath)
    # Start CMD and wait for it to finish its deletions
    $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c Setup.cmd" -Wait -NoNewWindow -PassThru
    Pop-Location
    
    if ($process.ExitCode -ne 0) {
        Write-Warning "Setup.cmd finished with errors (Exit Code: $($process.ExitCode))."
    }
}
else {
    Write-Host "Step 3: Setup.cmd not found, skipping cleanup." -ForegroundColor Gray
}

# --- 4. Deploy Fresh Files ---
Write-Host "Step 4: Moving fresh files to final destination..." -ForegroundColor Yellow
# This overwrites anything the CMD might have left behind and restores deleted files
Copy-Item -Path "$tempStage\*" -Destination $localRoot -Recurse -Force

# --- 5. Final Cleanup ---
Write-Host "Step 5: Cleaning up staging folder..." -ForegroundColor Yellow
Remove-Item $tempStage -Recurse -Force

Write-Host "`nSuccess: Lab07 environment is updated and synchronized!" -ForegroundColor Green