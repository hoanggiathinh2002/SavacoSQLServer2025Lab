<#
.SYNOPSIS
    Artifact script to grant NT AUTHORITY\SYSTEM sysadmin privileges in SQL Server 2022.
    Includes fixes for SQL 2022 SSL/Encryption connection errors.
#>

$ErrorActionPreference = "Stop"

Write-Host "--- Starting SQL Permission Update ---"

# 1. Ensure the SQL Server Service is running
$serviceName = "MSSQLSERVER"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($null -eq $service) {
    $service = Get-Service -Name "MSSQL$*" | Select-Object -First 1
    if ($null -eq $service) {
        Write-Error "SQL Server service not found."
        exit 1
    }
    $serviceName = $service.Name
}

if ($service.Status -ne 'Running') {
    Write-Host "Starting SQL Service: $serviceName..."
    Start-Service -Name $serviceName
    Start-Sleep -Seconds 10
}

# 2. Define the T-SQL Command
$tsql = @"
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'NT AUTHORITY\SYSTEM')
BEGIN
    CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS;
END
ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT AUTHORITY\SYSTEM];
"@

# 3. Execute using sqlcmd with the Trust Certificate flag (-C)
# -E: Trusted Connection
# -S: Server (.)
# -C: Trust Server Certificate (Fixes the SSL Provider error in SQL 2022)
# -b: Exit on error
Write-Host "Executing SQL command with Trust Certificate flag..."

try {
    & sqlcmd.exe -E -S "." -C -Q "$tsql" -b
    
    if ($LASTEXITCODE -ne 0) {
        throw "sqlcmd failed with exit code $LASTEXITCODE"
    }
    
    Write-Host "Successfully granted sysadmin rights to NT AUTHORITY\SYSTEM."
}
catch {
    Write-Host "Standard execution failed. Attempting via local named pipes with -C flag..."
    try {
        # Fallback to named pipes if TCP is blocked, still using -C
        & sqlcmd.exe -E -S "np:\\.\pipe\sql\query" -C -Q "$tsql" -b
        Write-Host "Successfully granted sysadmin rights via named pipes."
    }
    catch {
        Write-Error "Failed to update SQL permissions. Error: $($_.Exception.Message)"
        exit 1
    }
}

Write-Host "--- SQL Permission Update Complete ---"
