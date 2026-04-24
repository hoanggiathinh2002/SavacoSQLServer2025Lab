$path = "C:\SQLServerAdminLabs\LabFiles\Lab13\Starter\Setup-fake-mail-server.ps1"
$code = @"
Write-Host '--- Windows Server 2025: Starting smtp4dev ---' -ForegroundColor Cyan

# 1. Install smtp4dev if not present
if (!(dotnet tool list -g | Select-String 'Rnwood.Smtp4dev')) {
    Write-Host 'Installing smtp4dev...' -ForegroundColor Yellow
    dotnet tool install -g Rnwood.Smtp4dev
}

# 2. Kill any existing instances to avoid port conflicts
Stop-Process -Name 'smtp4dev' -Force -ErrorAction SilentlyContinue

# 3. Start the server
# Web UI on 3000, SMTP on 2525
smtp4dev --Urls 'http://*:3000' --smtpport 2525
"@

# This writes the file using basic ASCII to prevent encoding errors
[System.IO.File]::WriteAllText($path, $code)

Write-Host "Success! The script has been rebuilt at $path" -ForegroundColor Green
Write-Host "You can now run it using: .\Setup-fake-mail-server.ps1" -ForegroundColor White