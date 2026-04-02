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
