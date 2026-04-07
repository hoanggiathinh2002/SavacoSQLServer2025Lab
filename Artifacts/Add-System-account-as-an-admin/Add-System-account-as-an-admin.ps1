<#
.SYNOPSIS
    Forcefully grants sysadmin rights by restarting SQL in Single-User Mode.
    Necessary when the SYSTEM account is locked out of a new SQL 2022 instance.
#>

$ErrorActionPreference = "Stop"

# 1. Identify Service Name
$serviceName = (Get-Service -Name "MSSQLSERVER", "MSSQL$*" -ErrorAction SilentlyContinue | Select-Object -First 1).Name
if (-not $serviceName) { throw "SQL Server Service not found." }

Write-Host "--- Starting Forceful SQL Permission Update ---"

# 2. Stop SQL Server
Write-Host "Stopping SQL Server ($serviceName)..."
Stop-Service -Name $serviceName -Force

# 3. Start SQL Server in Single-User Mode (-mSQLCMD)
# This allows any member of the local Administrators group to connect.
Write-Host "Restarting SQL in Single-User Mode..."
Start-Process "sqlservr.exe" -ArgumentList "-s$serviceName", "-mSQLCMD", "-f" -WindowStyle Hidden
Start-Sleep -Seconds 15 # Give it time to initialize

# 4. Run the SQL Command
# We use -S "." and -C to handle the SQL 2022 encryption requirements
$tsql = "IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'NT AUTHORITY\SYSTEM') CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS; ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT AUTHORITY\SYSTEM];"

try {
    Write-Host "Injecting sysadmin rights..."
    & sqlcmd.exe -E -S "." -C -Q "$tsql" -b
    Write-Host "Injection successful."
}
catch {
    Write-Host "Injection failed: $($_.Exception.Message)"
}
finally {
    # 5. Clean up: Kill the single-user process and restart the normal service
    Write-Host "Restoring normal SQL service..."
    Get-Process "sqlservr" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 5
    Start-Service -Name $serviceName
}

Write-Host "--- Forceful Update Complete ---"
