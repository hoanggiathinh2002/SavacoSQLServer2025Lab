Write-Host "Checking for pending reboots to prepare for SQL Server..."
# We don't need complex logic here because 'rebootBehavior: always' 
# in the JSON will force a reboot as soon as this script exits with 0.
Write-Host "Rebooting machine to clear component-based servicing or file renames..."
exit 0



Write-Host "Checking if Chocolatey is installed..."

if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
    Write-Host "Chocolatey already installed."
    exit 0
}

Write-Host "Installing Chocolatey..."

Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Write-Error "Chocolatey installation failed."
    exit 1
}

Write-Host "Chocolatey installed successfully."
exit 0
