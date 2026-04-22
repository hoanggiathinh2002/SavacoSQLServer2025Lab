param (
    [Parameter(Mandatory = $false)]
)

# --- Configuration ---
$owner = "hoanggiathinh2002"
$repo = "SavacoSQLServer2025Lab"
$basePath = "Artifacts/Tools"
$localRoot = "C:\SQLServerAdminLabs\Tools\SwitchLab"

# --- Function to Download Recursively ---
function Get-GitHubFolder {
    param (
        [string]$RepoPath,
        [string]$LocalPath
    )

    # Ensure local directory exists
    if (!(Test-Path $LocalPath)) {
        New-Item -ItemType Directory -Path $LocalPath -Force | Out-Null
    }

    # GitHub API URL for the current folder
    $apiUrl = "https://api.github.com/repos/$owner/$repo/contents/$RepoPath"
    
    try {
        $items = Invoke-RestMethod -Uri $apiUrl -Method Get -UseBasicParsing
    }
    catch {
        Write-Error "Failed to reach GitHub API for path: $RepoPath"
        return
    }

    foreach ($item in $items) {
        $targetLocalPath = Join-Path $LocalPath $item.name

        if ($item.type -eq "dir") {
            # It's a folder: Recurse!
            Write-Output "Entering Folder: $($item.path)"
            Get-GitHubFolder -RepoPath $item.path -LocalPath $targetLocalPath
        } 
        elseif ($item.type -eq "file") {
            # It's a file: Download!
            Write-Output "Downloading File: $($item.name)"
            Invoke-WebRequest -Uri $item.download_url -OutFile $targetLocalPath -UseBasicParsing
        }
    }
}

# --- Execution ---
Write-Output "Starting recursive download from GitHub..."
Get-GitHubFolder -RepoPath $basePath -LocalPath $localRoot

# --- Post-Download Logic ---
$cmdPath = Join-Path $localRoot "SwitchLab.cmd"
if (Test-Path $cmdPath) {
    Set-Location (Split-Path $cmdPath)
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c SwitchLab.cmd" -Wait -NoNewWindow
}
Write-Host "`nSuccess: Switch Lab setup complete! You can find the files at: $localRoot"