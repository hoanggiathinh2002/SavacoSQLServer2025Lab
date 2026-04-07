<#
.SYNOPSIS
    Adds NT AUTHORITY\SYSTEM to the sysadmin role in SQL Server.
#>

$sqlCommand = @"
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'NT AUTHORITY\SYSTEM')
BEGIN
    CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS;
END
ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT AUTHORITY\SYSTEM];
"@

try {
    Write-Host "Connecting to local SQL instance..."
    # Invoke-Sqlcmd is the standard way to run T-SQL via PowerShell
    Invoke-Sqlcmd -Query $sqlCommand -ServerInstance "." -ErrorAction Stop
    Write-Host "Successfully added NT AUTHORITY\SYSTEM as sysadmin."
}
catch {
    Write-Error "Failed to update SQL permissions: $($_.Exception.Message)"
    exit 1
}
