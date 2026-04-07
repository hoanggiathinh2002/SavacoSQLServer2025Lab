<#
.SYNOPSIS
    Forcefully grants sysadmin rights by finding the SQL binary path and 
    restarting in Single-User Mode.
#>

$ErrorActionPreference = "Stop"

Write-Host "--- Starting Forceful SQL Permission Update ---"

# 1. Identify Service and Instance Name
$sqlService = Get-Service -Name "MSSQLSERVER", "MSSQL$*" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $sqlService) { throw "SQL Server Service not found." }
$serviceName = $sqlService.Name

# 2. Find the path to sqlservr.exe via Registry
Write-Host "Locating SQL binaries..."
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName"
$imagePath = (Get-ItemProperty $regPath).ImagePath.Replace('"', '')
# The ImagePath usually includes the "-s" arguments; we just want the .exe path
$exePath = $imagePath.Split('-')[0].Trim()

if (-not (Test-Path $exePath)) {
    throw "Could not find sqlservr.exe at $exePath"
}

# 3. Stop SQL Server
Write-Host "Stopping SQL Server ($serviceName)..."
Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue

# 4. Start SQL Server in Single-User Mode
# We use Start-Process with the full path discovered above
Write-Host "Restarting SQL from: $exePath"
$process = Start-Process -FilePath $exePath -ArgumentList "-mSQLCMD", "-c" -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 15 

# 5. Run the SQL Command
$tsql = "IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'NT AUTHORITY\SYSTEM') CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS; ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT AUTHORITY\SYSTEM];"

try {
    Write-Host "Injecting sysadmin rights..."
    # Using "." and "-C" for SQL 2022 compatibility
    & sqlcmd.exe -E -S "." -C -Q "$tsql" -b
    Write-Host "Injection successful."
}
catch {
    Write-Host "Injection failed: $($_.Exception.Message)"
}
finally {
    # 6. Clean up: Kill the process and restart the normal service
    Write-Host "Restoring normal SQL service..."
    if ($process) { Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue }
    Get-Process "sqlservr" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 5
    Start-Service -Name $serviceName
}

Write-Host "--- Forceful Update Complete ---"
