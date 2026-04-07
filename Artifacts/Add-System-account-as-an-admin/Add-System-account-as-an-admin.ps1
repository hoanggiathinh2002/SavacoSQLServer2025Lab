<#
.SYNOPSIS
    Artifact script to grant NT AUTHORITY\SYSTEM sysadmin privileges in SQL Server 2022.
    Designed for Azure DevTest Labs / Custom Script Extension.
#>

$ErrorActionPreference = "Stop"

Write-Host "--- Starting SQL Permission Update ---"

# 1. Ensure the SQL Server Service is running
$serviceName = "MSSQLSERVER"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($null -eq $service) {
    # If default instance isn't found, try to find any SQL service (like SQLEXPRESS)
    $service = Get-Service -Name "MSSQL$*" | Select-Object -First 1
    if ($null -eq $service) {
        Write-Error "SQL Server service not found on this machine."
        exit 1
    }
    $serviceName = $service.Name
}

if ($service.Status -ne 'Running') {
    Write-Host "Starting SQL Service: $serviceName..."
    Start-Service -Name $serviceName
    Start-Sleep -Seconds 10
}

# 2. Determine the Server Instance name for connection
# For default instances, this is "." or "localhost"
$serverInstance = "."

# 3. Define the T-SQL Command
# This creates the login if it doesn't exist and adds it to sysadmin
$tsql = @"
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'NT AUTHORITY\SYSTEM')
BEGIN
    CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS;
END
ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT AUTHORITY\SYSTEM];
"@

# 4. Execute using sqlcmd
Write-Host "Executing SQL command on $serverInstance..."

try {
    # -E: Use Trusted Connection
    # -b: On error, exit with a non-zero return code
    & sqlcmd.exe -E -S "$serverInstance" -Q "$tsql" -b
    
    if ($LASTEXITCODE -ne 0) {
        throw "sqlcmd failed with exit code $LASTEXITCODE"
    }
    
    Write-Host "Successfully granted sysadmin rights to NT AUTHORITY\SYSTEM."
}
catch {
    Write-Host "Standard execution failed. Attempting to use local pipe connection..."
    # Fallback for some configurations: try explicitly using the local protocol
    try {
        & sqlcmd.exe -E -S "np:\\.\pipe\sql\query" -Q "$tsql" -b
        Write-Host "Successfully granted sysadmin rights via named pipes."
    }
    catch {
        Write-Error "Failed to update SQL permissions. Error: $($_.Exception.Message)"
        exit 1
    }
}

Write-Host "--- SQL Permission Update Complete ---"
