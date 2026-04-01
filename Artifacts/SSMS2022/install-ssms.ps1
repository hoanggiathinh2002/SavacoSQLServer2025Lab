$ErrorActionPreference = "Stop"

# Microsoft's permanent link for the latest SSMS full setup
$ssmsDownloadUrl = "https://aka.ms/ssmsfullsetup"
$installerPath = "$env:TEMP\SSMS-Setup-ENU.exe"

Write-Host "Downloading latest SQL Server Management Studio from $ssmsDownloadUrl..."
# UseBasicParsing is included for compatibility with older PowerShell environments
Invoke-WebRequest -Uri $ssmsDownloadUrl -OutFile $installerPath -UseBasicParsing

Write-Host "Download complete. Starting silent installation of SSMS..."

# /Install: Installs the application
# /Quiet: Runs the installer with no UI
# /NoRestart: Suppresses any required reboots so the artifact doesn't hang the lab provisioning
$installArgs = "/Install /Quiet /NoRestart"

# Start the installer and wait for it to finish
$process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru

# Exit code 0 means success. Exit code 3010 means success, but a reboot is required.
if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
    Write-Host "SSMS installed successfully. (Exit code: $($process.ExitCode))"
    if ($process.ExitCode -eq 3010) {
        Write-Host "Note: A reboot may be required on this VM to complete the SSMS setup."
    }
} else {
    Write-Error "SSMS installation failed with exit code $($process.ExitCode)."
    exit $process.ExitCode
}

Write-Host "Cleaning up installer file..."
Remove-Item -Path $installerPath -Force

Write-Host "SSMS Artifact execution completed successfully."
